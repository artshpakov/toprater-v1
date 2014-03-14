class AlternativesController < ApplicationController

  respond_to :json

  def rate
    @alternatives = Voltdb::CriteriaRating.alternatives(Alternative.ids, params[:criterion_ids].split(","))
    respond_with @alternatives
  end

end
