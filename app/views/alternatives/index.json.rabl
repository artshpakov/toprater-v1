collection alternatives
attributes :id, :name, :score, :cover_url
node :top do |alternative|
  alternative.best_criteria(:with_ids => @criterion_ids).map do |criterion|
    { :id => criterion.criterion_id, :grade => criterion.rank }
  end
end
node(:realm) { "hotels" }
