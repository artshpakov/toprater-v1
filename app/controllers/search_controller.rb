class SearchController < ApplicationController

  respond_to :json

  def fetch
    @results = CompleteIndex.query(regexp: {name: "#{params[:q].downcase}.*"}).load
  end

end
