# Each task has input point and some of tasks has output points.
# Input point should be provided with INPUT_PATH env variable (same for OUTPUT_PATH).

require 'csv'

namespace :csv_import do

  # DATA_FILES_PATH = ENV['data_files_path'] || File.join('tmp', 'csv_import')
  TMP_PATH = Rails.root.join('tmp')

  # CRITERIA_CSV_PATH   = ENV['criteria_path']    || Rails.root.join(DATA_FILES_PATH, 'criteria.csv')
  # REVIEWS_CSV_PATH    = ENV['reviews_path']     || Rails.root.join(DATA_FILES_PATH, 'reviews.csv')
  # DETAILS_CSV_PATH    = ENV['details_path']     || Rails.root.join(DATA_FILES_PATH, 'details.csv')
  # HOTELS_DB_PATH      = ENV['hotels_db_path'] || Rails.root.join(DATA_FILES_PATH, 'tripadvisor-hotels-noreviews-it.db')
  # TRIADVISOR_DATA_DB_PATH = ENV['ta_db_path']   || Rails.root.join(DATA_FILES_PATH, 'tripadvisor-12-02-2014.db')

  # task :all => :environment do
  #   Rake::Task['csv_import:criteria'].invoke
  #   Rake::Task['csv_import:hotels'].invoke
  #   Rake::Task['csv_import:tripadvisor_reviews'].invoke
  #   Rake::Task['csv_import:alternatives_criterion_fast'].invoke
  #   Rake::Task['csv_import:review_sentences_fast'].invoke
  # end

  def input_path
    path = ENV['input_path']
    check_path!(path)
    path
  end

  def output_path
    path = ENV['output_path']
    check_path!(path)
    path
  end

  def check_path!(path)
    unless File.exists?(path)
      raise Exception, "File not found #{path}"
    end
  end

  task :delete_all => :environment do
    Alternative.delete_all
    AlternativesCriterion.delete_all
    Review.delete_all
    ReviewSentence.delete_all
    Property::Field.delete_all
    Criterion.delete_all
  end

  # Old data source: HOTELS_DB_PATH
  task :hotels => :environment do
    puts "Proccessing hotels from #{input_path}"
    db = Sequel.connect("sqlite://#{input_path}")

    progress_bar = ProgressBar.create(:title => 'hotels', :total => db[:hotels].count)

    db[:hotels].each do |hotel|
      progress_bar.increment

      record = Alternative.where(:ta_id => hotel[:ta_id], :realm_id => 1).first_or_initialize
      record.name  = hotel[:name]
      record.ta_id = hotel[:ta_id]
      record.lat   = hotel[:lat]
      record.lng   = hotel[:lng]
      record.save!

      # TODO: move to method
      # - Photo
      if hotel[:photo].present?
        medium = Medium::TripAdvisor.find_or_initialize_by(alternative_id: record.id, url: hotel[:photo], medium_type: 'image')
        medium.update_attributes(cover: true)
        KV.set "alt:#{record.id}:cover", medium.url(:thumb)
      end

      group = Property::Group.where(:name => Alternative::HOTEL_ATTRIBUTES_GROUP_NAME).first_or_create!

      # - Address
      if hotel[:address].present?
        field = Property::Field.where(:name => 'Address', :short_name => 'address', :group_id => group.id, :field_type => 'text').first_or_create!
        property = Property::Value.where(:field_id => field.id, :alternative_id => record.id).first_or_initialize
        property.value = hotel[:address]
        property.save! if property.value_changed?
      end

      # - Stars
      if hotel[:stars].present?
        field = Property::Field.where(:name => 'Stars', :short_name => 'stars', :group_id => group.id, :field_type => 'integer').first_or_create!
        property = Property::Value.where(:field_id => field.id, :alternative_id => record.id).first_or_initialize
        property.value = hotel[:stars]
        property.save! if property.value_changed?
      end

    end

    db.disconnect
  end

  # Old data source: TRIADVISOR_DATA_DB_PATH
  task :tripadvisor_reviews => :environment do
    puts "processing Reviews from #{input_path}"

    # csv file for export from sqlite3
    export_file_path = File.join(TMP_PATH, "export_#{Time.now.to_i}.csv")

    # export to sqlite3
    original_fields = {
      :ta_id => 'integer',
      :member => 'text',
      :body => 'text',
      :badges => 'text',
      :date => 'date',
      :rating => 'float',
      :title => 'varchar(255)',
      :url => 'varchar(255)',
      :hotel_id => 'integer',
      :lang => 'varchar(255)',
      :owner_response => 'boolean',
      :respond_to => 'integer'
    }

    `sqlite3 -header -csv #{input_path} "SELECT #{ original_fields.keys.join(', ') } FROM reviews" >> #{export_file_path}`

    # process in pg
    db = ActiveRecord::Base.connection

    # create TEMP table
    table_name = 'reviews_csv_import_temp'

    # import to TEMP table
    db.execute <<-SQL
      CREATE TEMP TABLE #{table_name} ( #{ original_fields.map { |k,v| "#{k} #{v}" }.join(', ') } );
      COPY #{table_name} FROM '#{export_file_path}' CSV HEADER;
      CREATE INDEX ta_id_idx ON #{table_name} (ta_id);
    SQL

    # # import from TEMP table to real table
    db.execute <<-SQL
      INSERT INTO reviews ( alternative_id, body, date, type, agency_id )
        SELECT
          alternatives.id,
          #{table_name}.body,
          #{table_name}.date,
          'Review::TripAdvisor',
          #{table_name}.ta_id
        FROM #{table_name}

        INNER JOIN
          alternatives ON alternatives.ta_id = #{table_name}.ta_id
    SQL
  end

  # Old data source: CRITERIA_CSV_PATH
  task :criteria => :environment do
    puts "Processing criteria from #{input_path}"
    pavel_criterion = Criterion.find_or_create_by(name: "Павел", short_name: "pavel")

    CSV.foreach(input_path, headers: true) do |row|
      record = Criterion.where(:short_name => row[1], :name => row[1]).first_or_create!
      record.update_attributes({ :parent => pavel_criterion, :external_id => row[0] })
    end

    puts "criteria processed"
  end

  task :alternatives_criterion_fast => :environment do
    db = ActiveRecord::Base.connection
    table_name = 'alternatives_criterion_temp'

    db.execute <<-SQL
      CREATE TEMP TABLE #{table_name} ( ta_id integer, criterion_id integer, rating float, reviews_count integer, rank integer );

      COPY #{table_name} FROM '#{input_path}' CSV;

      CREATE INDEX ta_id_idx ON #{table_name} (ta_id);
    SQL

    db.execute <<-SQL
      INSERT INTO alternatives_criteria (alternative_id, criterion_id, rating, reviews_count, rank)

        SELECT
          alternatives.id,
          criteria.id,
          #{table_name}.rating,
          #{table_name}.reviews_count,
          #{table_name}.rank

        FROM #{table_name}

        INNER JOIN
          alternatives ON alternatives.ta_id = #{table_name}.ta_id
        INNER JOIN
          criteria ON criteria.external_id = #{table_name}.criterion_id
    SQL

  end

  # Old data source: DETAILS_CSV_PATH
  task :review_sentences_fast => :environment do
    require 'benchmark'

    db = ActiveRecord::Base.connection
    db.execute('TRUNCATE review_sentences')

    # create TEMP table
    table_name = "csv_import_data_temp"
    db.execute("CREATE TEMP TABLE #{table_name} ( ta_id integer, agency_id integer, external_criterion_id integer, sent1 text, sent2 text, sent3 text, score float )")

    # fill TEMP table with data
    db.execute("COPY #{table_name} FROM '#{input_path}' CSV HEADER")
    db.execute("CREATE INDEX ta_and_agency_ids_idx ON #{table_name} (ta_id, agency_id)")

    bench = Benchmark.measure do

      db.execute <<-SQL
        INSERT INTO review_sentences ( alternative_id, criterion_id, review_id, sentences, score, created_at, updated_at )
          SELECT
            alternatives.id,
            criteria.id,
            reviews.id,
            array_to_json(ARRAY[#{table_name}.sent1, #{table_name}.sent2, #{table_name}.sent3]),
            #{table_name}.score,
            now(),
            now()

          FROM #{table_name}

          INNER JOIN
            alternatives ON alternatives.ta_id = #{table_name}.ta_id
          INNER JOIN
            reviews ON reviews.type = 'Review::Tripadvisor' AND reviews.agency_id = #{table_name}.agency_id
          INNER JOIN
            criteria ON criteria.external_id = #{table_name}.external_criterion_id
      SQL

    end

    puts bench

  end

  task :prepare_reviews_csv_for_import => :environment do
    File.new(output_path, 'w').close()

    criterion_ids = Criterion.where('external_id IS NOT NULL').pluck(:external_id)
    criterion_keys = {}
    criterion_ids.each { |id| criterion_keys[id] = "criteria_#{id}" }

    CSV.open(output_path, 'a') do |csv|
      CSV.foreach(input_path, :headers => true) do |row|

        # row -> ext_ta_id, ext_crit_id, rating, reviews_count, rank
        new_rows = []

        criterion_ids.each do |id|
          if row['count_' + id.to_s].to_i > 0
            new_rows << [ row['hotel_id'].to_i, id, row['criteria_' + id.to_s].to_f, row['count_' + id.to_s].to_i, row['rank_' + id.to_s].to_i ]
          end
        end

        new_rows.each do |new_row|
          csv << new_row
        end
      end
    end
  end

end
