object alternative

attributes :id, :name, :reviews_count, :cover_url
node(:realm) { "hotels" }

node :scores do
  raw_picked  = alternative.criteria_scores(@criterion_ids)
  raw_top     = alternative.top

  picked = raw_picked
  picked.keys.each do |id|
    percentage  = raw_picked[id]
    position    = raw_top[id]
    out_of      = (position || 1)+rand(150)
    picked[id]  = { percentage: percentage, position: position, out_of: out_of }
  end

  top = raw_top.delete_if { |id, position| id.in? raw_picked.keys }
  top.keys.each do |id|
    percentage  = raw_picked[id] || rand(100)
    position    = raw_top[id]
    out_of      = (position || 1)+rand(150)
    top[id]     = { percentage: percentage, position: position, out_of: out_of }
  end

  picked.merge top
end

node :relevant_reviews_count do
  alternative.count_relevant_reviews @criterion_ids
end

node :reviews do
  alternative.processed_reviews(@criterion_ids, limit: 10).tap do |rws|
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
