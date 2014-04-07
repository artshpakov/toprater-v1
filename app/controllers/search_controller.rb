class SearchController < ApplicationController

  respond_to :json

  def fetch
    criteria  = Criterion.where("name LIKE '#{ params[:query] }%'").limit 5
    filters   = Property::Field.where("name LIKE '#{ params[:query] }%'").limit 5
    @results  = (criteria + filters).shuffle
  end

end
