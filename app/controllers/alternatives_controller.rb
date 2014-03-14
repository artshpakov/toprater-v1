class AlternativesController < ApplicationController

  respond_to :json

  def rate
    respond_with Array.wrap Alternative.all.sample
  end

end
