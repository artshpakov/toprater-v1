class Criterion < ActiveRecord::Base

  validates_presence_of :name
  
  has_many :alternatives_criterions
  has_many :alternatives, through: :alternatives_criterions

  has_ancestry

end
