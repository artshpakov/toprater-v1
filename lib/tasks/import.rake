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

    DB.disconnect

    DB = Sequel.connect("sqlite://#{Rails.root}/tmp/maldives_processed.db")

    criteria = {}

    pavel_criterion = Criterion.find_or_create_by(name: "Павел", short_name: "pavel")

    DB[:criteria].each do |criterion_attributes|
      # binding.pry
      criterion = Criterion.find_or_create_by(name: criterion_attributes[:title])
      if criterion.id
        criterion.update_attribute :parent, pavel_criterion
        criteria[criterion_attributes[:id]] = criterion.id
      end
    end

    puts "Processed #{criteria.keys.size} criteria"

    DB[:reviews].each do |ratings_attributes|
      criteria.each_key do |crit_id|
        unless ratings_attributes[:"criteria_#{crit_id}"] == 0
          alt_crit = AlternativesCriterion.find_or_initialize_by(alternative_id: hotels[ratings_attributes[:hotel_id]], criterion_id: criteria[crit_id])
          alt_crit.update_attributes({rating: ratings_attributes[:"criteria_#{crit_id}"]})
        end
      end

    end

    DB.disconnect

    puts "Done"

  end


end
