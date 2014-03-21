class Property::Field < ActiveRecord::Base
  belongs_to :group
  has_many :values
end
