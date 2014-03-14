class AlternativesController < ApplicationController

  respond_to :json

  def rate
    @alternatives = Voltdb::CriterionsRating.alternatives(Alternative.ids, params[:criterion_ids].split(","))
    respond_with @alternatives
  end

end
