class AddRankToAlternativesCriteria < ActiveRecord::Migration
  def change
    add_column :alternatives_criteria, :rank, :integer
  end
end
