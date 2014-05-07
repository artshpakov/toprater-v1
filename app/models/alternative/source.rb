class Alternative::Source < ActiveRecord::Base
  belongs_to :alternative

  scope :orphans, -> { where(alternative_id: nil) }
  scope :with_geo, -> { where.not(lat: nil).where.not(lng: nil) }

  validates_presence_of :name

  def realm
    Realm.find(realm_id)
  end

end
