class ReviewSentence < ActiveRecord::Base
  belongs_to :alternative
  belongs_to :criterion
  belongs_to :review

  def score
    (super + 1) * 2.5
  end

  def score_percentage
    (score * 20).round
  end


end
