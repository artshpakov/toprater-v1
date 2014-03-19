class Review::Tripadvisor < Review

  def self.agency_name
    "TripAdvisor"
  end

  def self.agency_url
    "http://tripadvisor.com"
  end

  def tripadvisor_id
    agency_id
  end

end
