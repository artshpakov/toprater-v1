namespace :import do

  desc "Import criteria from a JSON file"
  task criteria: :environment do
    JSON.parse(File.read("#{ Rails.root }/db/criteria.dump.json")).map do |attributes|
      Criterion.create attributes
    end
  end

  desc "Import hotels from sqlite DB file"
  task hotels: :environment do
    DB = Sequel.connect("sqlite://#{Rails.root}/tmp/tripadvisor-maldives.db")

    hotels = {}

    DB[:hotels].each do |hotel_attributes|
      hotel = Alternative.find_or_create_by(name: hotel_attributes[:name])
      if hotel.id
        hotels[hotel_attributes[:ta_id]] = hotel.id
      end
    end
    
    puts "Processed #{hotels.keys.size} hotels"

    DB[:reviews].where(owner_response: nil).each do |review_attributes|
      hotel_id = hotels[review_attributes[:hotel_id]]
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

    DB.disconnect

    DB = Sequel.connect("sqlite://#{Rails.root}/tmp/maldives_processed.db")

    criteria = {}

    pavel_criterion = Criterion.find_or_create_by(name: "Павел", short_name: "pavel")

    DB[:criteria].each do |criterion_attributes|
      criterion = Criterion.find_or_create_by(short_name: criterion_attributes[:title], name: criterion_attributes[:title])
      if criterion.id
        criterion.update_attributes({parent: pavel_criterion, name: criterion_attributes[:title]})
        criteria[criterion_attributes[:id]] = criterion.id
      end
    end

    puts "Processed #{criteria.keys.size} criteria"

    DB[:reviews].each do |ratings_attributes|
      criteria.each_key do |crit_id|
        if !hotels[ratings_attributes[:hotel_id]].nil? and !criteria[crit_id].nil? and ratings_attributes[:"criteria_#{crit_id}"] > 0
          alt_crit = AlternativesCriterion.find_or_initialize_by(alternative_id: hotels[ratings_attributes[:hotel_id]], criterion_id: criteria[crit_id])
          if alt_crit.new_record?
            alt_crit.update_attributes({rating: ratings_attributes[:"criteria_#{crit_id}"], reviews_count: ratings_attributes[:"count_#{crit_id}"]})
          end
        end
      end
    end

    DB[:details].each do |details_attributes|
      criterion_id = criteria[details_attributes[:criteria]]
      review_id = Review::Tripadvisor.where(agency_id: details_attributes[:review_id]).pluck(:id).first
      sentence = ReviewSentence.find_or_initialize_by(alternative_id: hotels[details_attributes[:hotel_id]], criterion_id: criterion_id, review_id: review_id)
      sentence.update_attributes({sentences: [details_attributes[:sent1], details_attributes[:sent2], details_attributes[:sent3]], score: details_attributes[:score], review_id: review_id})
    end

    DB.disconnect

    puts "Done"

  end


end
