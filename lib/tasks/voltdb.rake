
namespace :voltdb do

  desc "Generate and load voltdb schema"
  task schema_load: :environment do
    
    criteria_columns = Criterion.all.map{|criterion| " cr_#{criterion.id} TINYINT" }.join(",")

    sql = "CREATE TABLE criteria_ratings ( alternative_id INTEGER NOT NULL,\n#{criteria_columns},\n CONSTRAINT criteria_ratings_alternative_index PRIMARY KEY ( alternative_id )\n);"

    voltdb_schema_path = "#{Rails.root}/db/voltdb/schema.sql"
    voltdb_jar_path = "#{Rails.root}/db/voltdb/compiled_schema.jar"

    if File.exists?(voltdb_schema_path)
      puts "Will rewrite #{voltdb_schema_path}"
    end

    File.open(voltdb_schema_path, "w") do |f|
      f.write(sql)
    end

    puts "\nDone. Now do something like this:\n$ #{File.join(Voltdb.bin_path, "voltdb")} compile #{voltdb_schema_path} -o #{voltdb_jar_path}\n$ #{File.join(Voltdb.bin_path, "voltdb")} create #{voltdb_jar_path}"

  end


  desc "Populate voltdb schema with data"
  task populate: :environment do
    criterion_ids = Criterion.where.not(ancestry: nil).pluck :id
    fields = criterion_ids.map { |criterion_id| "cr_#{ criterion_id }" }.join ','
    default_values = Hash[criterion_ids.collect { |id| [ id, 'NULL' ] }]

    Alternative.find_each do |alternative|
      values = default_values

      alternative.alternatives_criteria.each do |ac|
        values[ac.criterion_id] = ac.rating
      end

      Voltdb::CriteriaRating.execute_sql "INSERT INTO criteria_ratings(alternative_id, #{ fields }) VALUES (#{ entry.id }, #{ values.values.join(',') })"
    end

    puts "\nDone"
  end

end
