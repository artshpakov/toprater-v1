class IndexController < ApplicationController

  def index
    gon.realms = Realm.all

    @criteria = Criterion.roots
    gon.rabl template: "app/views/criteria/index.json.rabl", as: :criteria

    @properties = Property::Field.all
    gon.rabl template: "app/views/properties/index.json.rabl", as: :properties

    gon.preset = [[671, true], [467, false], [320, true], [209, true]]
  end

end
