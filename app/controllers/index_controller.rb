class IndexController < ApplicationController

  def index
    @criteria = Criterion.roots
    gon.rabl template: "app/views/criteria/index.json.rabl", as: :criteria

    @properties = Property::Group.includes(:fields)
    gon.rabl template: "app/views/properties/index.json.rabl", as: :properties
  end

end
