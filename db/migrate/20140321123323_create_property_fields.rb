class CreatePropertyFields < ActiveRecord::Migration
  def change
    create_table :property_fields do |t|
      t.references :group, index: true
      t.string :field_type, null: false
      t.string :name, null: false
      t.string :title, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
