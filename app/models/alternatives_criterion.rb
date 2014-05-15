class AlternativesCriterion < ActiveRecord::Base

  belongs_to :alternative
  belongs_to :criterion

  # ajust -1..1 scale to 1..5
  def corrected_rating
    [(weighted_rating + 2) * 1.6666666666666667, 5.0].min
  end

  # Using just average rating sucks. let's make first try in oh so many...
  def self.update_weighted_ratings!
    # (sigmoid( x - 5 ) + 0.75)/1.75 * R, where x is reviews_count
    # and R is an average rating
    # and sigmoid(x) = 1/(1 + e^-x)
    # results in reducing rating to a half for 0 reviews
    # and almost unchanged rating for 10 reviews
    # FIXME change to update_all with :placeholders, if needed
    connection.execute <<-"END"
      UPDATE alternatives_criteria
      SET weighted_rating = rating * (1/(1+exp(-(reviews_count - 5))) + 0.75) / 1.75
    END
  end

  def self.update_ranks!
    connection.execute <<-"END"
      WITH new_ranks AS (
        SELECT
          alternative_id,
          criterion_id,
          row_number() OVER(PARTITION BY criterion_id ORDER BY weighted_rating DESC) AS rank
        FROM alternatives_criteria
      )
      UPDATE alternatives_criteria
      SET rank = new_ranks.rank
      FROM new_ranks
      WHERE alternatives_criteria.alternative_id = new_ranks.alternative_id
        AND alternatives_criteria.criterion_id = new_ranks.criterion_id
    END
  end
end
