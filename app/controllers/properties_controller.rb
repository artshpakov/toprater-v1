class PropertiesController < ApplicationController
  respond_to :json

  def index
    @properties = Property::Group.includes(:fields)
  end
end
