namespace :import do

  desc "Import hotels from sqlite DB file"
  task hotels: :environment do
    DB = Sequel.connect("sqlite://#{Rails.root}/tmp/tripadvisor-data.db")

    hotels = {}

    DB[:hotels].each do |hotel_attributes|
      hotel = Alternative.find_or_create_by(name: hotel_attributes[:name])
      if hotel.id
        hotels[hotel_attributes[:ta_id]] = hotel.id
        if hotel_attributes[:photo].present?
          medium = Medium::TripAdvisor.find_or_initialize_by(alternative_id: hotel.id, url: hotel_attributes[:photo], medium_type: 'image')
          medium.update_attributes(cover: true)
        end
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
            short_name = fac_property.downcase.gsub(/[\-\s]+/, "_").gsub(/[^A-Za-z_]/, "")
            field = group.fields.find_by(short_name: short_name) || group.fields.new(name: fac_property, short_name: short_name, field_type: 'boolean')
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

end
