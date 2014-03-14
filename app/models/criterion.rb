class Criterion < ActiveRecord::Base

  validates_presence_of :name
  
  has_many :alternatives_criteria
  has_many :alternatives, through: :alternatives_criteria

  has_ancestry

end
