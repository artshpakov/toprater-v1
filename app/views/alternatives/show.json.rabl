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
  @criterion_ids.map do |c_id|
    { :id => c_id.to_i, :grade => alternative.alternatives_criteria.where(:criterion_id => c_id).first.try(:rank) }
  end
end

node :thumbnails do
  alternative.media.map &:url rescue []
end
