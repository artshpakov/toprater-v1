class AddRealmIdToAlternatives < ActiveRecord::Migration
  def change
    add_column :alternatives, :realm_id, :integer
  end
end
