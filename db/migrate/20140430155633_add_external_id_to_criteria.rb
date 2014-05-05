class AddExternalIdToCriteria < ActiveRecord::Migration
  def change
    add_column :criteria, :external_id, :integer
  end
end
