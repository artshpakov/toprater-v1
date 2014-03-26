class Alternative < ActiveRecord::Base

  has_many :alternatives_criteria
  has_many :criteria, through: :alternatives_criteria
  has_many :reviews
  has_many :review_sentences

  has_many :property_values, class_name: 'Property::Value'

  validates :name, presence: true

  attr_accessor :score, :properties

end
