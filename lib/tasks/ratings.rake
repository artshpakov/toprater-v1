namespace :ratings do

  desc "Import hotels from sqlite DB file"
  task build: :environment do

    $redis.keys("top50:alt_rating:*").each{|k| $redis.del(k)}
    criteria = Criterion.where.not(ancestry: nil).pluck(:id)
    criteria.each do |criterion_id|
      grade = 0
      last_score = nil
      scored_alternatives = Hash[AlternativesIndex.score_by([criterion_id]).limit(21).only(:id).to_a.map{|x| [x.id, x._score]}]
      scored_alternatives.each do |alternative_id, score|
        if last_score.nil? or last_score > score
          grade += 1
          last_score = score
        end
        $redis.get("top50:alt_rating:#{alternative_id}").tap do |current_ratings|
          current_ratings ||= "{}"
          current_ratings = JSON.parse(current_ratings)
          current_ratings.merge!({criterion_id => grade})
          current_ratings = Hash[current_ratings.sort_by{|k,v| v}]
          $redis.set "top50:alt_rating:#{alternative_id}", current_ratings.to_json
        end
      end
    print "." if Rails.env == 'development'
    end

  end
end
