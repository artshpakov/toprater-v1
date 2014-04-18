object alternative

attributes :id, :name, :reviews_count, :cover_url
node(:realm) { "hotels" }

node :reviews do
  alternative.processed_reviews @criterion_ids
end

node :scores do
  alternative.criteria_scores @criterion_ids
end

node :relevant_reviews_count do
  alternative.count_relevant_reviews @criterion_ids
end

node :top do |alternative|
  alternative.top.map { |id, grade| { id: id.to_i, grade: grade } }
end

node :thumbnails do
  alternative.media.map &:url rescue []
end
