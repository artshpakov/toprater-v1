class SearchController < ApplicationController

  respond_to :json

  def index
    @results = CompleteIndex.query(regexp: {name: "#{params[:q].downcase}.*"}).load
  end

end
