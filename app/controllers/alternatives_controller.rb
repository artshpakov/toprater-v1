class AlternativesController < ApplicationController

  inherit_resources

  respond_to :json
  custom_actions collection: [:rate]

  helper_method :alternative, :alternatives

  def rate
    @alternatives = Voltdb::CriteriaRating.alternatives(params[:criterion_ids].split(","))
    respond_with alternatives
  end

protected
  def alternative
    AlternativeDecorator.decorate resource
  end

  def alternatives
    AlternativeDecorator.decorate_collection collection
  end

end
