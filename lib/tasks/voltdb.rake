
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
  task :compile do
    %x( voltdb compile #{ schema_path } -o #{ jar_path } )
    puts "  Schema compiled"
  end


  desc "Create VoltDB session"
  task :create do
    %x( voltdb create -B #{ jar_path } )
    puts "  VoltDB session created"
  end


  desc "Populate VoltDB schema with data"
  task populate: :environment do
    criterion_ids = Criterion.where.not(ancestry: nil).pluck :id
    fields = criterion_ids.map { |criterion_id| "cr_#{ criterion_id }" }.join ','
    default_values = Hash[criterion_ids.collect { |id| [ id, 'NULL' ] }]

    Alternative.find_each do |alternative|
      values = default_values

      alternative.alternatives_criteria.each do |ac|
        values[ac.criterion_id] = ac.rating
      end

      Voltdb::CriteriaRating.execute_sql "INSERT INTO criteria_ratings(alternative_id, #{ fields }) VALUES (#{ alternative.id }, #{ values.values.join(',') })"
    end

    puts "  Populated schema"
  end


  desc "Prepare VoltDB schema & data"
  task :setup do
    Rake::Task['voltdb:schema_load'].invoke && Rake::Task['voltdb:compile'].invoke && Rake::Task['voltdb:create'].invoke && Rake::Task['voltdb:populate'].invoke
  end


  private

  def schema_path
    "#{Rails.root}/db/voltdb/schema.sql"
  end

  def jar_path
    "#{Rails.root}/db/voltdb/compiled_schema.jar"
  end

end
