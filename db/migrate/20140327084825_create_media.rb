class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.references :alternative, index: true
      t.string :type, index: true
      t.string :agency_id, index: true
      t.string :url
      t.string :medium_type, index: true
      t.boolean :cover
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
