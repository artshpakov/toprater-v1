class Alternative < ActiveRecord::Base

  has_many :alternatives_criteria
  has_many :criteria, through: :alternatives_criteria
  has_many :reviews

  validates :name, presence: true

end
