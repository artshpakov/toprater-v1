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
    #TODO: filters will be moved to VoltDB soon
    filtered_alternatives = Alternative
    alternatives_ids = nil
    if params[:property_ids] and params[:property_ids].any?
      filtered_alternatives = filtered_alternatives.joins(:property_values)
      params[:property_ids].each do |id, value|
        filtered_alternatives = filtered_alternatives.where(property_values: {field_id: id, value: value})
      end
      alternatives_ids = filtered_alternatives.limit(200).pluck(:id)
    end


    if alternatives_ids and !alternatives_ids.any?
      @alternatives = []
      return
    end

    @alternatives = Voltdb::CriteriaRating.select

    if alternatives_ids and alternatives_ids.any?
      @alternatives = @alternatives.where(alternative_id: alternatives_ids)
    end

    if params[:criterion_ids].present?
      @criterion_ids = params[:criterion_ids].split(",")
      @alternatives = @alternatives.order(@criterion_ids)
    end

    @alternatives = @alternatives.load
  end

  def count
    filtered_alternatives = Alternative
    if params[:property_ids] and params[:property_ids].any?
      filtered_alternatives = filtered_alternatives.joins(:property_values)
      params[:property_ids].each do |property, value|
        filtered_alternatives = filtered_alternatives.where(property_values: {field_id: property.to_i, value: value})
      end
    end

    respond_with count: filtered_alternatives.count
  end

protected
  def alternative
    AlternativeDecorator.decorate resource
  end

  def alternatives
    AlternativeDecorator.decorate_collection collection
  end

end
