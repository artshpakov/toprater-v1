class Alternative < ActiveRecord::Base

  has_many :alternatives_criteria, dependent: :delete_all
  has_many :criteria, through: :alternatives_criteria
  has_many :reviews, dependent: :destroy
  has_many :review_sentences, dependent: :delete_all
  has_many :media, dependent: :destroy
  has_many :sources

  has_many :property_values, class_name: 'Property::Value', dependent: :delete_all

  validates :name, presence: true

  attr_accessor :score, :properties

  def cover_url
    KV.get("alt:#{id}:cover") || "/images/no_picture.png"
  end

  def best_criteria(options = {}, limit = 5)
    result = self.alternatives_criteria.order('rank DESC').limit(limit).to_a

    if options[:with_ids].present?
      result.unshift( self.alternatives_criteria.where(:criterion_id => options[:with_ids]).to_a )
    end

    return result.flatten.uniq { |c| c.criterion_id }.sort_by { |c| c.rank }.reverse
  end

  def realm
    Realm.find(realm_id)
  end

end
