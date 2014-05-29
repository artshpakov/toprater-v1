# FIXME: this is hardcode for current, but should become well normalized db
class Country

  def self.names
    @names ||= Alternative.select('distinct(country_name)').map(&:country_name)
  end

end
