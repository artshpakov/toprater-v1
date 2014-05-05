class AddCoordinatesToAlternatives < ActiveRecord::Migration
  def change
    add_column :alternatives, :lat, :real
    add_column :alternatives, :lng, :real
  end
end
