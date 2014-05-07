class Property::Field < ActiveRecord::Base

  include AllSuffixes

  belongs_to :group
  has_many :values
end
