class Review < ActiveRecord::Base
  belongs_to :alternative, counter_cache: true
  has_many :review_sentences, dependent: :delete_all
end
