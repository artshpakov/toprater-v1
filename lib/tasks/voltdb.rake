
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

    puts ""
    puts "Done. Now do something like this:\n$ #{File.join(Voltdb.bin_path, "voltdb")} compile #{voltdb_schema_path} -o #{voltdb_jar_path}\n$ #{File.join(Voltdb.bin_path, "voltdb")} create #{voltdb_jar_path}"

  end

end
