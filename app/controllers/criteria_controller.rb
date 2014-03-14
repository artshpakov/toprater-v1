class CriteriaController < ApplicationController

  respond_to :json

  def index
    @criteria = Criterion.roots
  end

end
