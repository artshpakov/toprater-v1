class ReviewSentence < ActiveRecord::Base
  belongs_to :alternative
  belongs_to :criterion
  belongs_to :review
end
