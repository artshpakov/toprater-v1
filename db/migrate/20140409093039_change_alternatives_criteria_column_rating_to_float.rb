class ChangeAlternativesCriteriaColumnRatingToFloat < ActiveRecord::Migration
  def self.up
    change_column :alternatives_criteria, :rating, :float
  end

  def self.down
    change_column :alternatives_criteria, :rating, :integer
  end

end
