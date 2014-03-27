object alternative
attributes :id, :name, :reviews_count, :score, :cover_url
node :reviews do
  alternative.processed_reviews @criterion_ids
end
node :relevant_reviews_count do
  alternative.count_relevant_reviews @criterion_ids
end
