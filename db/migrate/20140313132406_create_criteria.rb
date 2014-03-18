class CreateCriteria < ActiveRecord::Migration

  def change
    create_table :criteria do |t|
      t.string :name, null: false
      t.string :short_name
      t.string :description
      t.integer :status, null: false, default: 0
      t.string :ancestry
    end
    add_index :criteria, :ancestry
  end

end
