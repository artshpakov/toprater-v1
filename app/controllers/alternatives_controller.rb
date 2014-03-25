class AlternativesController < ApplicationController

  inherit_resources
  custom_actions collection: [:count]

  respond_to :json

  helper_method :alternative, :alternatives

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

  def index
    @alternatives = Voltdb::CriteriaRating.select
    if params[:properties] and params[:properties].any?
      params[:properties].each do |property, value|
        @alternatives = @alternatives.where(properties: {property => value})
      end
    end

    if params[:criterion_ids].present?
      @criterion_ids = params[:criterion_ids].split(",")
      @alternatives = @alternatives.score_by(@criterion_ids)
    end

    @alternatives = @alternatives.load
  end

  def count
    @alternatives = Voltdb::CriteriaRating.select
    if params[:properties] and params[:properties].any?
      params[:properties].each do |property, value|
        @alternatives = @alternatives.where(properties: {property => value})
      end
    end

    respond_with @alternatives.count.load
  end

protected
  def alternative
    AlternativeDecorator.decorate resource
  end

  def alternatives
    AlternativeDecorator.decorate_collection collection
  end

end
