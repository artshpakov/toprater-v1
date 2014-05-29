class AddCountryAndLocationToAlternatives < ActiveRecord::Migration
  def change
    add_column :alternatives, :location_name, :string
    add_column :alternatives, :country_name, :string
  end
end
