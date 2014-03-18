class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.references :alternative, index: true
      t.text :body
      t.date :date
    end
  end
end
