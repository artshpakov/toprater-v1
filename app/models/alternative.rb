class Alternative < ActiveRecord::Base

  validates :name, presence: true

  has_many :alternatives_criteria
  has_many :criteria, through: :alternatives_criteria

end
