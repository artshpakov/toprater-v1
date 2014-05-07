namespace :adopt do
  desc "Adopt lonely alternative sources"
  task alternatives: :environment do

    matches = 0
    Alternative::Source.orphans.with_geo.find_each do |alternative_source|
      alternatives = AlternativesIndex.filter({geo_distance: {distance: "2km", location: [alternative_source[:lng], alternative_source[:lat]]}})

      alternatives.each do |alternative|
        alternative_name = alternative.name.downcase.gsub(" hotel", "").gsub("hotel ", "")
        if alternative_source.name.downcase.gsub(" hotel", "").gsub("hotel ", "") == alternative_name
          alternative_source.update_attributes(alternative_id: alternative.id)
          matches += 1
          next
        end
      end
    end

    puts "#{matches} matches"
  end
end
