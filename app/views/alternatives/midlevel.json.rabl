object alternative

attributes :id, :name, :reviews_count, :cover_url
node(:realm) { "hotels" }

node :scores do
  raw_picked = alternative.criteria_scores(@criterion_ids)

  result = {}

  @criterion_ids.each do |c_id|
    result[c_id] = {
      'percentage' => raw_picked[c_id.to_i],
      'position'   => alternative.alternatives_criteria.where(:criterion_id => c_id).first.try(:rank),
      'out_of'     => Criterion.find(c_id).alternatives_criteria.count
    }
  end

  result
end

node :relevant_reviews_count do
  alternative.count_relevant_reviews @criterion_ids
end

node :reviews do
  alternative.processed_reviews(@criterion_ids).tap do |rws|
    rws.each { |cid, rw| rws[cid] = partial('review_sentences/show', object: rw) }
  end
end

node :media do
  # TODO: move to serializer
  alternative.media.not_covers.limit(5).map do |media|
    { :small_url => media.url(:small), :thumb_url => media.url(:thumb), :preview_url => media.url(:preview) }
  end
end


# node :reviews do
#   alternative.reviews(limit: 2).map { |rw| partial 'review_sentences/show', object: rw }
# end
