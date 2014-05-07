class SearchController < ApplicationController

  respond_to :json

  def index
    @results = CompleteIndex.complete_loaded_with_corrections(params[:q], size: 8)
  end

end
