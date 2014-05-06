require 'csv'

namespace :csv_import do

  DATA_FILES_PATH = ENV['data_files_path'] || File.join('tmp', 'csv_import')

  CRITERIONS_CSV_PATH = ENV['criterions_path'] || Rails.root.join(DATA_FILES_PATH, 'criteria.csv')
  REVIEWS_CSV_PATH    = ENV['reviews_path']    || Rails.root.join(DATA_FILES_PATH, 'reviews.csv')
  DETAILS_CSV_PATH    = ENV['details_path']    || Rails.root.join(DATA_FILES_PATH, 'details.csv')
  HOTELS_DB_PATH      = ENV['hotels_db_path']  || Rails.root.join(DATA_FILES_PATH, 'tripadvisor-data.db')
  HOTELS_2_DB_PATH    = ENV['hotels_2_db_path'] || Rails.root.join(DATA_FILES_PATH, 'tripadvisor-hotels-noreviews-it.db')
  TRIADVISOR_DATA_DB_PATH = ENV['ta_db_path'] || Rails.root.join(DATA_FILES_PATH, 'tripadvisor-12-02-2014.db')

  task :all => :environment do
    Rake::Task['csv_import:criterions'].invoke
    Rake::Task['csv_import:hotels'].invoke
    Rake::Task['csv_import:hotels_2'].invoke
    Rake::Task['csv_import:tripadvisor_reviews'].invoke
    Rake::Task['csv_import:alternatives_criterion'].invoke
    Rake::Task['csv_import:review_sentences'].invoke
  end

  desc "old shitty hotels data (count: 160)"
  task :hotels => :environment do
    db = Sequel.connect("sqlite://#{HOTELS_DB_PATH}")

    db[:hotels].each do |hotel_attributes|
      hotel = Alternative.where(:name => hotel_attributes[:name], :realm_id => 1).first_or_initialize
      hotel.ta_id = hotel_attributes[:ta_id]
      hotel.lat   = hotel_attributes[:lat]
      hotel.lng   = hotel_attributes[:lng]
      hotel.save!

      # TODO: move to method
      if hotel_attributes[:photo].present?
        medium = Medium::TripAdvisor.find_or_initialize_by(alternative_id: hotel.id, url: hotel_attributes[:photo], medium_type: 'image')
        medium.update_attributes(cover: true)
        KV.set "alt:#{hotel.id}:cover", medium.url(:thumb)
      end
    end

    db.disconnect
  end

  task :hotels_2 => :environment do
    puts "Proccessing hotels from #{HOTELS_2_DB_PATH}"
    db = Sequel.connect("sqlite://#{HOTELS_2_DB_PATH}")


    count = 0
    db[:hotels].each do |hotel|
      count += 1
      record = Alternative.where(:name => hotel[:name], :realm_id => 1).first_or_initialize
      record.ta_id = hotel[:ta_id]
      record.lat   = hotel[:lat]
      record.lng   = hotel[:lng]
      record.save!

      # TODO: move to method
      if hotel[:photo].present?
        medium = Medium::TripAdvisor.find_or_initialize_by(alternative_id: record.id, url: hotel[:photo], medium_type: 'image')
        medium.update_attributes(cover: true)
        KV.set "alt:#{record.id}:cover", medium.url(:thumb)
      end
    end

    puts "Processed #{count} hotels"
    db.disconnect
  end

  task :tripadvisor_reviews => :environment do
    puts "processing Reviews from #{TRIADVISOR_DATA_DB_PATH}"
    db = Sequel.connect("sqlite://#{TRIADVISOR_DATA_DB_PATH}")

    db[:reviews].where(owner_response: nil).each do |review_attributes|
      hotel_id = Alternative.where(:ta_id => review_attributes[:hotel_id]).first.try(:id)
      if hotel_id
        review = Review::Tripadvisor.find_or_initialize_by(alternative_id: hotel_id, agency_id: review_attributes[:ta_id])
        if review.new_record?
          review_attributes[:date] = begin
            Time.parse(review_attributes[:date])
          rescue
            nil
          end
          review.update_attributes(review_attributes.slice(:body, :date))
        end
      end
    end

    db.disconnect
  end

  task :criterions => :environment do
    puts "Processing criterions from #{CRITERIONS_CSV_PATH}"
    pavel_criterion = Criterion.find_or_create_by(name: "Павел", short_name: "pavel")

    CSV.foreach(CRITERIONS_CSV_PATH, headers: true) do |row|
      record = Criterion.where(:short_name => row[1], :name => row[1]).first_or_create!
      record.update_attributes({ :parent => pavel_criterion, :external_id => row[0] })
    end

    puts "criterions processed"
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
