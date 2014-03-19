class AlternativesController < ApplicationController

  inherit_resources

  respond_to :json
  custom_actions collection: [:rate]

  helper_method :alternative, :alternatives, :reviews

  def show
    respond_to do |format|
      format.html do
        render "index/index"
      end
      format.json do
        @alternative = Alternative.find_by! id: params[:id]
        @criterion_ids = params[:criterion_ids].split(',')
      end
    end
  end


  def rate
    @criterion_ids = params[:criterion_ids].split(",")
    @alternatives = Voltdb::CriteriaRating.alternatives @criterion_ids
  end

protected
  def alternative
    AlternativeDecorator.decorate resource
  end

  def alternatives
    AlternativeDecorator.decorate_collection collection
  end

end
