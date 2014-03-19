class Alternative < ActiveRecord::Base

  has_many :alternatives_criteria
  has_many :criteria, through: :alternatives_criteria
  has_many :reviews
  has_many :review_sentences

  validates :name, presence: true

end
