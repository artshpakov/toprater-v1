class Alternative < ActiveRecord::Base

  has_many :alternatives_criteria, dependent: :delete_all
  has_many :criteria, through: :alternatives_criteria
  has_many :reviews, dependent: :destroy
  has_many :review_sentences, dependent: :delete_all
  has_many :media, dependent: :destroy

  has_many :property_values, class_name: 'Property::Value', dependent: :delete_all

  validates :name, presence: true

  attr_accessor :score, :properties

  def cover_url
    KV.get("alt:#{id}:cover") || "/images/no_picture.png"
  end

  def top
    JSON.parse(KV.get("top50:alt_rating:#{id}") || "{}")
  end

  def realm
    Realm.find(realm_id)
  end

end
