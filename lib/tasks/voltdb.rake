namespace :voltdb do

  desc "Generate and load VoltDB schema"
  task schema_load: :environment do    

    sql = "CREATE TABLE kv ( key VARCHAR(250) NOT NULL, value VARCHAR(1048576) NOT NULL, PRIMARY KEY (key));\nPARTITION TABLE kv ON COLUMN key;\n"

    criteria_columns = Criterion.where.not(ancestry: nil).order('id ASC').map{|criterion| " cr_#{criterion.id} FLOAT" }.join(",")

    sql += "CREATE TABLE criteria_ratings ( alternative_id INTEGER NOT NULL,\n#{criteria_columns},\nPRIMARY KEY ( alternative_id )\n);\nPARTITION TABLE criteria_ratings ON COLUMN alternative_id;\n"

    properties_columns = Property::Field.order('id ASC').map do |field|
      " prop_#{field.id} #{field.voltdb_type}"
    end.join(",")

    sql += "CREATE TABLE alternatives_properties ( alternative_id INTEGER NOT NULL,\n#{properties_columns},\nPRIMARY KEY ( alternative_id )\n);\nPARTITION TABLE alternatives_properties ON COLUMN alternative_id;\n"

    puts "Will rewrite #{schema_path}" if File.exists?(schema_path)
    File.open(schema_path, "w") { |f| f.write(sql) }
    puts "  Generated schema"
  end


  desc "Compile VoltDB schema"
  task compile: :environment do
    check_process { |pid| abort "  VoltDB already running with PID #{pid}" }
    File.delete jar_path if File.exists? jar_path
    %x( #{Voltdb.voltdb_executable_path} compile #{ schema_path } -o #{ jar_path } )
    abort "  Error. Could not compile VoltDB schema" unless File.exists? jar_path
    puts "  Schema compiled"
  end


  desc "Create VoltDB session"
  task create: :environment do
    check_process { |pid| abort "  VoltDB already running with PID #{pid}" }

    %x( #{Voltdb.voltdb_executable_path} create -B #{ jar_path } -H #{Voltdb.host}:#{Voltdb.port} --http #{Voltdb.http_port} )
    sleep 10

    if File.exists?(Voltdb.pid_file)
      puts "  VoltDB session created with PID #{File.read(Voltdb.pid_file)}"
    else
      abort "  Could not start VoltDB. Check log for details #{Voltdb.log_file}"
    end
  end


  desc "Kill VoltDB session"
  task kill: :environment do
    check_process { |pid| %x(kill #{ pid } && rm #{Voltdb.pid_file}) }
    sleep 3
    puts "  VoltDB process killed"
  end


  desc "Populate VoltDB schema with data"
  task populate: :environment do
    # abort "  Voltdb doesn't running" if !check_process

    criterion_ids = Criterion.where.not(ancestry: nil).order('id ASC').map(&:id)
    criterion_fields = criterion_ids.map { |criterion_id| "cr_#{ criterion_id }" }.join ','
    criteria_default_values = Hash[criterion_ids.collect { |id| [ id, 'NULL' ] }]

    property_ids = Property::Field.order('id ASC').map(&:id)
    properties_fields = property_ids.map { |property_id| "prop_#{ property_id }" }.join ','
    properties_default_values = Hash[property_ids.collect { |id| [ id, 'NULL' ] }]

    Alternative.find_each do |alternative|
      print "." if Rails.env == 'development'
      criteria_values = criteria_default_values.dup

      alternative.alternatives_criteria.each do |ac|
        criteria_values[ac.criterion_id] = (ac.rating+1)*2.5
      end

      Voltdb::CriteriaRating.execute_sql "INSERT INTO criteria_ratings (alternative_id, #{ criterion_fields }) VALUES (#{ alternative.id }, #{ criteria_values.values.join(',') })"

      properties_values = properties_default_values.dup

      alternative.property_values.each do |ap|
        properties_values[ap.field_id] = ap.value
      end      

      Voltdb::CriteriaRating.execute_sql "INSERT INTO alternatives_properties (alternative_id, #{ properties_fields }) VALUES (#{ alternative.id }, #{ properties_values.values.join(',') })"

      alternative.media.covers.first.tap do |cover|
        Voltdb::Kv.set "alt:#{alternative.id}:cover", cover.url(:thumb) if cover
      end
    end

    puts "\n  Build alterantives rating"

    Voltdb::Kv.del "top50:alt_by_crit:*"
    criteria = Criterion.where.not(ancestry: nil).pluck(:id)
    criteria.each do |criterion_id|
      grade = 0
      last_score = nil
      scored_alternatives = Voltdb::CriteriaRating.select.score_by(criterion_id).limit(20).ids.load
      scored_alternatives.each do |alternative_id, score|
        if last_score.nil? or last_score > score
          grade += 1
          last_score = score
        end
        Voltdb::Kv.get("top50:alt_rating:#{alternative_id}").tap do |current_ratings|
          current_ratings ||= "{}"
          current_ratings = JSON.parse(current_ratings)
          current_ratings.merge!({criterion_id => grade})
          current_ratings = Hash[current_ratings.sort_by{|k,v| v}]
          Voltdb::Kv.set "top50:alt_rating:#{alternative_id}", current_ratings.to_json
        end
      end
    print "." if Rails.env == 'development'
    end

    puts "\n  Populated schema"
  end


  desc "Prepare VoltDB schema & data"
  task setup: :environment do
    Rake::Task['voltdb:schema_load'].invoke && Rake::Task['voltdb:compile'].invoke && Rake::Task['voltdb:create'].invoke && Rake::Task['voltdb:populate'].invoke
  end


  desc "Restart VoltDB"
  task reload: :environment do
    Rake::Task['voltdb:kill'].invoke
    sleep 3
    Rake::Task['voltdb:setup'].invoke
  end


private

  def schema_path
    "#{Rails.root}/db/voltdb/schema.sql"
  end

  def jar_path
    "#{Rails.root}/db/voltdb/compiled_schema.jar"
  end


  def check_process &block
    if File.exists?(Voltdb.pid_file)
      pid = File.read(Voltdb.pid_file).to_i
      begin
        Process.getpgid(pid)
        return block.call pid if block_given?
        return pid
      rescue Errno::ESRCH
        puts "  Voltdb: found stale pid file"
        File.delete(Voltdb.pid_file)
      end  
    end
    nil
  end

end
