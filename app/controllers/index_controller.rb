class IndexController < ApplicationController

  def index
    gon.realms = Realm.all

    @criteria = Criterion.roots
    gon.rabl template: "app/views/criteria/index.json.rabl", as: :criteria

    @properties = Property::Field.all
    gon.rabl template: "app/views/properties/index.json.rabl", as: :properties
 
    presets = Criterion.where(short_name: ['sea', 'boat trip', 'heathy food', 'chef']).pluck(:id)
    presets = Criterion.order("RANDOM()").limit(4).pluck(:id) if presets.empty?

    gon.preset = presets.map{|pf| [pf, true]}

  end

end
