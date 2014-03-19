class CreateReviewSentences < ActiveRecord::Migration
  def change
    create_table :review_sentences do |t|
      t.references :alternative, index: true
      t.references :criterion, index: true
      t.references :review, index: true
      t.json :sentences
      t.float :score

      t.timestamps
    end
  end
end
