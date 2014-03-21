class Property::Value < ActiveRecord::Base
  belongs_to :alternative
  belongs_to :field
end
