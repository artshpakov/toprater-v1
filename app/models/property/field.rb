class Property::Field < ActiveRecord::Base

  include AllSuffixes

  belongs_to :group
  has_many :values

  scope :with_types, ->(types) { where(:field_type => types) }

end
