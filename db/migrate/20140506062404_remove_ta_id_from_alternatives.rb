class RemoveTaIdFromAlternatives < ActiveRecord::Migration
  def change
    remove_column :alternatives, :ta_id
  end
end
