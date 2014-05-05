class AddTaIdToAlternatives < ActiveRecord::Migration
  def change
    add_column :alternatives, :ta_id, :integer
  end
end
