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

    @alternatives = AlternativesIndex.limit(21)

    if params[:prop] and params[:prop].any?
      properties = Hash[params[:prop].map{|k,v| ["prop_#{k}", v]}]
      @alternatives = @alternatives.merge(AlternativesIndex.filter(term: properties)) # FIXME potential hole
    end

    if @criterion_ids.any?
      @alternatives = @alternatives.merge(AlternativesIndex.score_by(@criterion_ids))
    end

    @alternatives = @alternatives.load
  end


  protected

  def alternative
    AlternativeDecorator.decorate resource
  end

  def alternatives
    AlternativeDecorator.decorate_collection collection
  end

end
