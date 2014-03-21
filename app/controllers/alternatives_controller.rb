class AlternativesController < ApplicationController

  inherit_resources

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
    @criterion_ids = params[:criterion_ids].split(",")

    filtered_alternatives = Alternative
    alternatives_ids = nil
    if params[:properties] and params[:properties].any?
      fields = Property::Field.where(name: params[:properties].keys).map{|field| {field.name => field.id}}.reduce Hash.new, :merge

      filtered_alternatives = filtered_alternatives.joins(:property_values)
      params[:properties].each do |property, value|
        filtered_alternatives = filtered_alternatives.where(property_values: {field_id: fields[property], value: value})
      end
      alternatives_ids = filtered_alternatives.limit(500).pluck(:id)
    end

    @alternatives = Voltdb::CriteriaRating.alternatives @criterion_ids, alternatives_ids
  end

protected
  def alternative
    AlternativeDecorator.decorate resource
  end

  def alternatives
    AlternativeDecorator.decorate_collection collection
  end

end
