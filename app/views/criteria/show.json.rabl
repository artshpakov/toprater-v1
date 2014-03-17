object @criterion
attributes :id, :name, :short_name
child descendants: :children do
  attributes :id, :name, :short_name, :parent_id, :depth
end
