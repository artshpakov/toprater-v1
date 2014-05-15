collection alternatives
attributes :id, :name, :score, :cover_url
node :top do |alternative|
  alternative.best_criteria({ with_ids: @criterion_ids }, 10).map do |criterion|
    { :id => criterion.criterion_id, :grade => criterion.rank, :rating => criterion.corrected_rating.round(1) }
  end
end
node(:top_count) { |alternative| alternative.alternatives_criteria.count }
node(:realm) { "hotels" }
