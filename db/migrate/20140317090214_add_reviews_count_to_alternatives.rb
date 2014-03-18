class AddReviewsCountToAlternatives < ActiveRecord::Migration
  def change
    add_column :alternatives, :reviews_count, :integer, default: 0, null: false
  end
end
