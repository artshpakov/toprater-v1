namespace :ratings do

  desc "Rebuild top50 alternatives by criteria ladder"
  task rebuild: :environment do

    KV.keys("top50:alt_rating:*").each{|k| KV.del(k)}
    criteria = Criterion.rated.pluck(:id)
    criteria.each do |criterion_id|
      grade = 0
      scored_alternatives = Hash[AlternativesIndex.score_by([criterion_id]).limit(50).only(:id).to_a.map{|x| [x.id, x._score]}]
      scored_alternatives.each do |alternative_id, score|
        break if score == 0
        grade += 1
        KV.get("top50:alt_rating:#{alternative_id}").tap do |current_ratings|
          current_ratings ||= "{}"
          current_ratings = JSON.parse(current_ratings)
          current_ratings.merge!({criterion_id => grade})
          current_ratings = Hash[current_ratings.sort_by{|k,v| v}]
          KV.set "top50:alt_rating:#{alternative_id}", current_ratings.to_json
        end
      end
    print "." if Rails.env == 'development'
    end

  end

end
