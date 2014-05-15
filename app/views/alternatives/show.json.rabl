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
  records = alternative.alternatives_criteria.where(:id => @criterion_ids).to_a

  records.map do |record|
    { :id => record.id, :grade => record.rank, :rating => recor.corrected_rating.round(1) }
  end
end

node :thumbnails do
  alternative.media.map &:url rescue []
end
