class PropertiesController < ApplicationController
  respond_to :json

  def index
    @properties = Property::Value.all
  end
end
