class RenamePropertyFieldsNameAndTitleColumns < ActiveRecord::Migration
  def change
    rename_column :property_fields, :name, :short_name
    rename_column :property_fields, :title, :name
  end
end
