class AddWeightedRatingToAlternativesCriteria < ActiveRecord::Migration
  def change
    change_table :alternatives_criteria do |t|
      t.float "weighted_rating"
    end
  end
end
