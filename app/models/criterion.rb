class Criterion < ActiveRecord::Base

  has_many :alternatives_criteria
  has_many :alternatives, through: :alternatives_criteria
  has_many :review_sentences

  has_ancestry

  validates_presence_of :name

end
