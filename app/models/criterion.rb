class Criterion < ActiveRecord::Base

  validates_presence_of :name

  has_ancestry

end
