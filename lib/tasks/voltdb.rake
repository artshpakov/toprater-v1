namespace :voltdb do

  desc "Generate and load VoltDB schema"
  task schema_load: :environment do    
    criteria_columns = Criterion.all.map{|criterion| " cr_#{criterion.id} TINYINT" }.join(",")

    sql = "CREATE TABLE criteria_ratings ( alternative_id INTEGER NOT NULL,\n#{criteria_columns},\n CONSTRAINT criteria_ratings_alternative_index PRIMARY KEY ( alternative_id )\n);"

    puts "Will rewrite #{schema_path}" if File.exists?(schema_path)
    File.open(schema_path, "w") { |f| f.write(sql) }
    puts "  Generated schema"
  end


  desc "Compile VoltDB schema"
  task compile: :environment do
    %x( #{Voltdb.voltdb_executable_path} compile #{ schema_path } -o #{ jar_path } )
    puts "  Schema compiled"
  end


  desc "Create VoltDB session"
  task create: :environment do
    check_process { |pid| abort "  VoltDB already running with PID #{pid}" }

    %x( #{Voltdb.voltdb_executable_path} create -v -B #{ jar_path } )
    sleep 3

    if File.exists?(Voltdb.pid_file)
      puts "  VoltDB session created with PID #{File.read(Voltdb.pid_file)}"
    else
      abort "  Could not start VoltDB. Check log for details #{Voltdb.log_file}"
    end
  end


  desc "Kill VoltDB session"
  task kill: :environment do
    check_process { |pid| %x(kill #{ pid }) }
    puts "  VoltDB process killed"
  end


  desc "Restart VoltDB"
  task restart: :environment do
    Rake::Task['voltdb:kill'].invoke
    sleep 3
    Rake::Task['voltdb:create'].invoke
  end


  desc "Populate VoltDB schema with data"
  task populate: :environment do
    criterion_ids = Criterion.where.not(ancestry: nil).pluck :id
    fields = criterion_ids.map { |criterion_id| "cr_#{ criterion_id }" }.join ','
    default_values = Hash[criterion_ids.collect { |id| [ id, 'NULL' ] }]

    Alternative.find_each do |alternative|
      print "."
      values = default_values

      alternative.alternatives_criteria.each do |ac|
        values[ac.criterion_id] = ac.rating
      end

      Voltdb::CriteriaRating.execute_sql "INSERT INTO criteria_ratings(alternative_id, #{ fields }) VALUES (#{ alternative.id }, #{ values.values.join(',') })"
    end

    puts "\n  Populated schema"
  end


  desc "Prepare VoltDB schema & data"
  task setup: :environment do
    Rake::Task['voltdb:schema_load'].invoke && Rake::Task['voltdb:compile'].invoke && Rake::Task['voltdb:create'].invoke && Rake::Task['voltdb:populate'].invoke
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
        block.call pid
      rescue Errno::ESRCH
        File.delete(Voltdb.pid_file)
      end  
    end
  end

end
