collection alternatives
attributes :id, :name, :score, :cover_url
node :top do |alternative|
  alternative.best_criteria({ with_ids: @criterion_ids }, 10).map do |criterion|
    { :id => criterion.criterion_id, :grade => criterion.rank }
  end
end
node(:top_count) { |alternative| alternative.best_criteria(with_ids: @criterion_ids).count }
node(:realm) { "hotels" }
