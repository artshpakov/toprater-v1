class AddStarsToAlternatives < ActiveRecord::Migration
  def change
    add_column :alternatives, :stars, :integer
  end
end
