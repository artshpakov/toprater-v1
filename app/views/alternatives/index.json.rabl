collection alternatives
attributes :id, :name, :reviews_count, :avg_score
node :relevant_reviews_count do |alternative|
  alternative.count_relevant_reviews @criterion_ids
end
