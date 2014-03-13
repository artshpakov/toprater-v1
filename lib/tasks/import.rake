namespace :import do

  desc "Import criteria from a JSON file"
  task criteria: :environment do
    JSON.parse(File.read("#{ Rails.root }/db/criteria.dump.json")).map do |attributes|
      Criterion.create attributes
    end
  end

end
