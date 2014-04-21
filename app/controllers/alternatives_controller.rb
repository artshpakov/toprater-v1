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
        @criterion_ids = params[:criterion_ids].split(',') if params[:criterion_ids].present?
      end
    end
  end

  def index
    @criterion_ids = (params[:criterion_ids] || '').split(",")

    alternatives_query = AlternativesIndex.limit(21)

    if params[:prop].present?
      properties = params[:prop].map{|k,v| {term: {"prop_#{k}" => v.to_s}} }
      alternatives_query = alternatives_query.merge(AlternativesIndex.filter(bool: {must: properties}))
    end

    if @criterion_ids.present?
      alternatives_query = alternatives_query.merge(AlternativesIndex.score_by(@criterion_ids))
    end

    # this is madness!
    alternatives_query = alternatives_query.only(:id).to_a

    alternative_ids = alternatives_query.map{|x| x.id.to_i}
    scores = alternatives_query.map(&:_score)

    @alternatives = alternative_ids.any? ? Alternative.where(id: alternative_ids) : []

    if @criterion_ids.any?
      sorted_alternatives = []
      @alternatives.each do |a|
        position = alternative_ids.index(a.id)
        a.score = scores[position]
        sorted_alternatives[position] = a
      end
      @alternatives = sorted_alternatives
    end

  end


  protected

  def alternative
    AlternativeDecorator.decorate resource
  end

  def alternatives
    AlternativeDecorator.decorate_collection collection
  end

end
