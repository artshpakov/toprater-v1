class Review < ActiveRecord::Base
  belongs_to :alternative, counter_cache: true
end
