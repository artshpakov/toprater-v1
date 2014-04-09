object @alternative
attributes :id, :name, :reviews_count, :score, :cover_url

child :alternatives_criteria do
  attributes :criterion_id, :rating
end
child :property_values do
  attributes :field_id, :value
end
