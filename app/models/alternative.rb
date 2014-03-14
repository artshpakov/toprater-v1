class Alternative < ActiveRecord::Base

  validates :name, presence: true

  has_many :alternatives_criterions
  has_many :criterions, through: :alternatives_criterions

end
