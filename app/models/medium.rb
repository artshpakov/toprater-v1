class Medium < ActiveRecord::Base
  belongs_to :alternative

  scope :covers, -> { where(cover: true) }

end
