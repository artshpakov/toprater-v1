object alternative

attributes :id, :name, :reviews_count, :cover_url
node(:realm) { "hotels" }

node :scores do
  raw_picked  = alternative.criteria_scores(@criterion_ids)
  raw_top     = alternative.top

  picked = alternative.criteria_scores(@criterion_ids).map do |id, score|
    position  = raw_top[id]
    out_of    = (position || 1)+rand(150)
    { id: id, score: score, position: position, out_of: out_of }
  end

  top = raw_top.delete_if { |id, position| id.in? raw_picked.keys }.map do |id, position|
    score     = raw_picked[id] || rand(100)
    out_of    = (position || 1)+rand(150)
    { id: id, score: score, position: position, out_of: out_of }
  end

  { picked: picked, top: top }
end

node :relevant_reviews_count do
  alternative.count_relevant_reviews @criterion_ids
end

node :reviews do
  alternative.reviews(limit: 2).map { |rw| partial 'review_sentences/show', object: rw }
end
