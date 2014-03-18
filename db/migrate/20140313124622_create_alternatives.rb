class CreateAlternatives < ActiveRecord::Migration

  def change
    create_table :alternatives do |t|
      t.string :name, null: false
    end
  end

end
