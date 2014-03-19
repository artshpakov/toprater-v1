object alternative
attributes :id, :name, :reviews_count, :avg_score
code :reviews do
  reviews = alternative.review_sentences.where(criterion_id: @criterion_ids)
  Hash[@criterion_ids.map do |cid|
    [ cid, reviews.select { |r| r.criterion_id == cid.to_i }.map{|rw| {score: (rw.score.to_f*100/5).round, sentences: rw.sentences}} ]
  end]
end
code :relevant_reviews_count do
  alternative.review_sentences.where(criterion_id: @criterion_ids).count
end
