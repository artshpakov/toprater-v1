class CreatePropertyValues < ActiveRecord::Migration
  def change
    create_table :property_values do |t|
      t.references :alternative, index: true
      t.references :field, index: true
      t.text :value

      t.timestamps
    end
  end
end
