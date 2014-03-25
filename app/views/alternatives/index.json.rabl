collection @alternatives
attributes :alternative_id
node :score do |alternative|
  (alternative.score*100/5).round if alternative.respond_to? :score
end
child :object do |object|
  decorated_object = AlternativeDecorator.decorate object
  attributes :id, :name, :reviews_count
  node :reviews do
    decorated_object.processed_reviews @criterion_ids
  end
  node :relevant_reviews_count do
    decorated_object.count_relevant_reviews @criterion_ids
  end
end
node :properties do |alternative|
  []
end
