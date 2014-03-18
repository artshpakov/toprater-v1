class CreateAlternativesCriteria < ActiveRecord::Migration
  def change
    create_table :alternatives_criteria, id: false do |t|
      t.references :alternative, index: true
      t.references :criterion
      t.integer :rating
    end
    add_index :alternatives_criteria, [:criterion_id, :alternative_id], unique: true

  end
end
