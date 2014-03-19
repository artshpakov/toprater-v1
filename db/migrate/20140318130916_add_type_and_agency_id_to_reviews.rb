class AddTypeAndAgencyIdToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :type, :string
    add_column :reviews, :agency_id, :integer
    add_index :reviews, [:type, :agency_id]
  end
end
