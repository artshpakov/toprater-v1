require 'csv'

namespace :csv_import do

  DATA_FILES_PATH = ENV['data_files_path'] || File.join('tmp', 'csv_import')

  CRITERIA_CSV_PATH   = ENV['criteria_path']    || Rails.root.join(DATA_FILES_PATH, 'criteria.csv')
  REVIEWS_CSV_PATH    = ENV['reviews_path']     || Rails.root.join(DATA_FILES_PATH, 'reviews.csv')
  DETAILS_CSV_PATH    = ENV['details_path']     || Rails.root.join(DATA_FILES_PATH, 'details.csv')
  HOTELS_DB_PATH      = ENV['hotels_db_path'] || Rails.root.join(DATA_FILES_PATH, 'tripadvisor-hotels-noreviews-it.db')
  TRIADVISOR_DATA_DB_PATH = ENV['ta_db_path']   || Rails.root.join(DATA_FILES_PATH, 'tripadvisor-12-02-2014.db')

  task :all => :environment do
    Rake::Task['csv_import:criteria'].invoke
    Rake::Task['csv_import:hotels'].invoke
    Rake::Task['csv_import:tripadvisor_reviews'].invoke
    Rake::Task['csv_import:alternatives_criterion'].invoke
    Rake::Task['csv_import:review_sentences'].invoke
  end

  task :delete_all => :environment do
    Alternative.delete_all
    AlternativesCriterion.delete_all
    Review.delete_all
    ReviewSentence.delete_all
    Property::Field.delete_all
    Criterion.delete_all
  end

  task :hotels => :environment do
    puts "Proccessing hotels from #{HOTELS_DB_PATH}"
    db = Sequel.connect("sqlite://#{HOTELS_DB_PATH}")

    progress_bar = ProgressBar.create(:title => 'hotels', :total => db[:hotels].count)

    db[:hotels].each do |hotel|
      progress_bar.increment

      record = Alternative.where(:name => hotel[:name], :realm_id => 1).first_or_initialize
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

  task :tripadvisor_reviews => :environment do
    puts "processing Reviews from #{TRIADVISOR_DATA_DB_PATH}"

    # csv file for export from sqlite3
    export_file_path = File.join(Rails.root, DATA_FILES_PATH, "export_#{Time.now.to_i}.csv")

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

    `sqlite3 #{TRIADVISOR_DATA_DB_PATH} "SELECT #{ original_fields.keys.join(', ') } FROM reviews" -header -csv >> #{export_file_path}`

    # process in pg
    db = ActiveRecord::Base.connection

    # create TEMP table
    table_name = 'reviews_csv_import_temp'

    db.execute <<-SQL
      CREATE TEMP TABLE #{table_name} ( #{ original_fields.map { |k,v| "#{k} #{v}" }.join(', ') } );
    SQL

    # import to TEMP table
    db.execute <<-SQL
      COPY #{table_name} FROM '#{export_file_path}' CSV HEADER;
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

  task :criteria => :environment do
    puts "Processing criteria from #{CRITERIA_CSV_PATH}"
    pavel_criterion = Criterion.find_or_create_by(name: "Павел", short_name: "pavel")

    CSV.foreach(CRITERIA_CSV_PATH, headers: true) do |row|
      record = Criterion.where(:short_name => row[1], :name => row[1]).first_or_create!
      record.update_attributes({ :parent => pavel_criterion, :external_id => row[0] })
    end

    puts "criteria processed"
  end

  task :alternatives_criterion => :environment do
    puts "Proccessing AlternativesCriterion from #{REVIEWS_CSV_PATH}" 

    counters = { :processed => 0, :created => 0 }

    CSV.foreach(REVIEWS_CSV_PATH, headers: true) do |row|
      counters[:processed] += 1

      hotel_id = Alternative.where(:ta_id => row[0]).first.try(:id)
      next if hotel_id.nil?

      Criterion.all.each do |criterion|
        criteria_count = row["count_#{criterion.external_id}"]

        if criteria_count.to_i > 0
          record = AlternativesCriterion.where(:alternative_id => hotel_id, :criterion_id => criterion.id).first_or_initialize

          if record.new_record? # really?
            record.reviews_count = criteria_count
            record.rating        = row["criteria_#{criterion.external_id}"]
            record.rank          = row["rank_#{criterion.external_id}"]
            record.save!

            counters[:created] += 1
          end
        end
      end

    end # CSV.foreach

    puts "Reviews.csv processed"
    puts counters.inspect

  end # task :reviews

  task :review_sentences_fast => :environment do
    require 'benchmark'

    db = ActiveRecord::Base.connection
    db.execute('TRUNCATE review_sentences')

    # create TEMP table
    table_name = "csv_import_data_temp"
    db.execute("CREATE TEMP TABLE #{table_name} ( ta_id integer, agency_id integer, external_criterion_id integer, sent1 text, sent2 text, sent3 text, score float )")
    db.execute("CREATE INDEX ta_and_agency_ids_idx ON #{table_name} (ta_id, agency_id)")

    # fill TEMP table with data
    db.execute("COPY #{table_name} FROM '#{DETAILS_CSV_PATH}' CSV HEADER")

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

  task :review_sentences => :environment do
    puts "Processing ReviewSentence from #{DETAILS_CSV_PATH}"

    counters = { :missied_criteria_or_review => 0, :created => 0}

    CSV.foreach(DETAILS_CSV_PATH, headers: true) do |row|
      criterion_id = Criterion.where(:external_id => row[2]).last.try(:id)
      hotel_id     = Alternative.where(:ta_id => row[0]).first.try(:id)
      review_id    = Review::Tripadvisor.where(:agency_id => row[1].to_i).first.try(:id)

      if criterion_id.blank? or review_id.blank?
        counters[:missied_criteria_or_review] += 1
        next
      end

      record = ReviewSentence.where(:alternative_id => hotel_id, :criterion_id => criterion_id, :review_id => review_id).first_or_initialize

      if record.new_record?
        record.sentences = [ row[3], row[4], row[5] ]
        record.score     = row[6]
        record.save!

        counters[:created] += 1
      end

    end # CSV.foreach

    puts counters.inspect
  end # task :details

end
