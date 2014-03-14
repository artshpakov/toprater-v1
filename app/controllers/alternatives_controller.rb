class AlternativesController < ApplicationController

  respond_to :json

  def rate
    respond_with params[:criterion_ids]
  end

end
