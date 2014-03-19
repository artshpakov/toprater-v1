collection alternatives
attributes :id, :name, :reviews_count, :avg_score
node :relevant_reviews_count do |alternative|
  alternative.alternatives_criteria.where(criterion_id: @criterion_ids).sum :reviews_count
end
