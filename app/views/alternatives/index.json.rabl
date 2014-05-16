collection alternatives

attributes :id, :name, :score, :cover_url

node :top do |alternative|
  alternative.best_criteria(with_ids: @criterion_ids, limit: 2).map do |criterion|
    { :id => criterion.criterion_id, :grade => criterion.rank, :rating => criterion.corrected_rating.round(1) }
  end
end

# TODO: rename to ~alternative.alternatives_criteria.count, this is not a top
node(:top_count) { |alternative| alternative.alternatives_criteria.count }

# TODO: maybe this is presenter/or model layer?
node(:realm) { "hotels" }
