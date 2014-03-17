class AddReviewsCountToAlternativesCriteria < ActiveRecord::Migration
  def change
    add_column :alternatives_criteria, :reviews_count, :integer, default: 0, null: false
  end
end
