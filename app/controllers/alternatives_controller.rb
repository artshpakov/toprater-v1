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
        @criterion_ids = params[:criterion_ids].split(',') if params[:criterion_ids].present?
      end
    end
  end

  def index
    @criterion_ids = (params[:criterion_ids] || '').split(",")
    @alternatives = AlternativesIndex
      .score_by(@criterion_ids)
      .filter(term: params[:props]) # FIXME potential hole
      .limit(21).load

    # @alternatives = Voltdb::CriteriaRating.select
    # if params[:prop] and params[:prop].any?
    #   params[:prop].each do |property, value|
    #     @alternatives = @alternatives.where(properties: {property => value})
    #   end
    # end

    # if params[:criterion_ids].present?
    #   @criterion_ids = params[:criterion_ids].split(",")
    #   @alternatives = @alternatives.score_by(@criterion_ids)
    # end

    @alternatives = @alternatives.limit(21).load
  end


  protected

  def alternative
    AlternativeDecorator.decorate resource
  end

  def alternatives
    AlternativeDecorator.decorate_collection collection
  end

end
