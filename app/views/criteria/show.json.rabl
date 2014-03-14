object @criterion
attributes :id, :name, :short_name
child children: :children do
  extends "criteria/show"
end
