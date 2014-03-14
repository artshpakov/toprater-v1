class IndexController < ApplicationController

  def index
    @criteria = Criterion.roots
    gon.rabl template: "app/views/criteria/index.json.rabl", as: :criteria
  end

end
