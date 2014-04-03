class SearchController < ApplicationController

  respond_to :json

  def fetch
    @results = Criterion.where("name LIKE '#{ params[:query] }%'").limit 10
  end

end
