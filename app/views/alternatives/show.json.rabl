object @alternative
attributes :id, :name, :reviews_count
code :reviews do
  reviews = @alternative.review_sentences.where(criterion_id: @criterion_ids)
  Hash[@criterion_ids.map do |cid|
    [ cid, reviews.select { |r| r.criterion_id == cid.to_i }.map(&:sentences) ]
  end]
end
code :relevant_reviews_count do
  @alternative.review_sentences.where(criterion_id: @criterion_ids).count
end
