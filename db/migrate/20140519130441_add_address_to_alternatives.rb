class AddAddressToAlternatives < ActiveRecord::Migration
  def change
    add_column :alternatives, :address, :text
  end
end
