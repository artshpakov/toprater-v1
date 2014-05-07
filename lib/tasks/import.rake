require 'csv'

namespace :import do

  desc "Import hotels from sqlite DB file"
  task hotels: :environment do
    DB = Sequel.connect("sqlite://#{Rails.root}/tmp/tripadvisor-data.db")

    hotels = 0

    DB[:hotels].each do |hotel_attributes|
      hotel = Alternative.find_or_initialize_by(name: hotel_attributes[:name], realm_id: 1)
      hotel.lat = hotel_attributes[:lat]
      hotel.lng = hotel_attributes[:lng]
      hotel.save!
      if hotel.id
        hotels += 1
        hotel_source = hotel.sources.find_or_initialize_by(type: 'Alternative::Source::Tripadvisor', agency_id: hotel_attributes[:ta_id].to_s, realm_id: 1)
        hotel_source.name = hotel_attributes[:name]
        hotel_source.lat = hotel_attributes[:lat]
        hotel_source.lng = hotel_attributes[:lng]
        hotel_source.save!

        if hotel_attributes[:photo].present?
          medium = Medium::TripAdvisor.find_or_initialize_by(alternative_id: hotel.id, url: hotel_attributes[:photo], medium_type: 'image')
          medium.update_attributes(cover: true)
          KV.set "alt:#{hotel.id}:cover", medium.url(:thumb)
        end
      end
    end

    puts "Processed #{hotels} hotels"

    DB[:reviews].where(owner_response: nil).each do |review_attributes|
      alternative_id = Alternative::Source::Tripadvisor.where(agency_id: review_attributes[:hotel_id].to_s).pluck(:alternative_id).first
      if alternative_id
        review = Review::Tripadvisor.find_or_initialize_by(alternative_id: alternative_id, agency_id: review_attributes[:ta_id])
        if review.new_record?
          review_attributes[:date] = Time.parse(review_attributes[:date]) rescue nil
          review.update_attributes(review_attributes.slice(:body, :date))
        end
      end
    end

    DB.disconnect

    DB = Sequel.connect("sqlite://#{Rails.root}/tmp/processed-data.db")

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
        alternative_id = Alternative::Source::Tripadvisor.where(agency_id: ratings_attributes[:hotel_id].to_s).pluck(:alternative_id).first

        if alternative_id and criteria[crit_id] and ratings_attributes[:"count_#{crit_id}"] > 0
          alt_crit = AlternativesCriterion.find_or_initialize_by(alternative_id: alternative_id, criterion_id: criteria[crit_id])

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

  desc "Import alternatives properties from sqlite DB file"
  task booking: :environment do

    DB = Sequel.connect("sqlite://#{Rails.root}/tmp/booking-data.db")
    counter = 0
    DB[:hotels].each do |booking_hotel|
      hotel = Alternative.where(name: booking_hotel[:name]).first
      if hotel
        if booking_hotel[:photo].present?
          medium = Medium::Booking.find_or_create_by(alternative_id: hotel.id, url: booking_hotel[:photo], medium_type: 'image')
        end

        counter += 1
        JSON.parse(booking_hotel[:facilities]).each do |fac_group, fac_properties|
          group = Property::Group.find_or_create_by(name: fac_group)

          fac_properties.each do |fac_property|
            short_name = fac_property.downcase.gsub(/[\-\s]+/, "_").gsub(/[^A-Za-z_]/, "").truncate(253)
            field = group.fields.find_by(short_name: short_name) || group.fields.new(name: fac_property.truncate(253), short_name: short_name, field_type: 'boolean')
            if field.save!
              value = field.values.find_or_initialize_by(alternative_id: hotel.id)
              value.value = '1'
              value.save!
            end
          end
        end
      end
    end
    p "Processed #{counter} hotels"
    
  end

  namespace :solvertour do
    desc "Import solvertour hotels"
    task hotels: :environment do

      counter = 0
      CSV.foreach(File.join(Rails.root, 'tmp/solvertour-hotels.csv'), headers: true) do |hotel_attributes|
        hotel_source = Alternative::Source::Solvertour.find_or_initialize_by(agency_id: hotel_attributes["_id"], realm_id: 1)
        hotel_source.name = hotel_attributes["name"]
        if hotel_attributes["lat"] and hotel_attributes["lon"]
          hotel_source.lat = hotel_attributes["lat"]
          hotel_source.lng = hotel_attributes["lon"]
        end
        hotel_source.data = {}
        hotel_source.save!
        counter += 1
      end

      puts "Processed #{counter} hotel sources"
    end

    desc "Import solvertour media"
    task media: :environment do

      counter = 0
      CSV.foreach(File.join(Rails.root, 'tmp/solvertour-media.csv'), headers: true) do |medium_attributes|
        alternative_id = Alternative::Source::Solvertour.where(agency_id: medium_attributes["hotel_id"]).pluck(:alternative_id).first
        if alternative_id
          medium = Medium::Solvertour.find_or_initialize_by(alternative_id: alternative_id, agency_id: medium_attributes["_id"])
          medium.url = medium_attributes["path"]
          medium.save!
          counter += 1
        end
      end

      puts "Processed #{counter} solvertour media"
    end

  end

end
