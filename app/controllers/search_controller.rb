class SearchController < ApplicationController

  respond_to :json

  def index
    @results = CompleteIndex.complete_loaded(params[:q], size: 8)
  end

end
