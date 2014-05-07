class CreateAlternativeSources < ActiveRecord::Migration
  def change
    create_table :alternative_sources do |t|
      t.references :alternative, index: true
      t.string :name
      t.integer :realm_id
      t.string :agency_id
      t.string :type
      t.text :url
      t.float :lat
      t.float :lng
      t.json :data

      t.timestamps
    end
    add_index :alternative_sources, :agency_id
    add_index :alternative_sources, :realm_id
    add_index :alternative_sources, :type
  end
end
