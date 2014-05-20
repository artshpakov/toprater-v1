class Alternative < ActiveRecord::Base

  HOTEL_ATTRIBUTES_GROUP_NAME = 'Hotel attributes'
  STARS_PROPERTY_FIELD_SHORT_NAME = 'stars'

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

  def best_criteria(with_ids: [], limit: nil)
    result = self.alternatives_criteria.order('rank DESC').limit(limit).to_a

    if with_ids.present?
      result.unshift( self.alternatives_criteria.where(:criterion_id => with_ids).to_a )
    end

    return result.flatten.uniq { |c| c.criterion_id }.sort_by { |c| c.rank }.reverse
  end

  def realm
    Realm.find(realm_id)
  end

  def self.stars_property_id
    if group = Property::Group.where(:name => HOTEL_ATTRIBUTES_GROUP_NAME).first
      field = Property::Field.where(:group_id => group.id, :short_name => STARS_PROPERTY_FIELD_SHORT_NAME).first

      field.try(:id)
    end
  end

end
