collection alternatives
attributes :id, :name, :score, :reviews_count
node :reviews do |alternative|
  alternative.processed_reviews @criterion_ids
end
node :relevant_reviews_count do |alternative|
  alternative.count_relevant_reviews @criterion_ids
end
