class Alternative::Source::Tripadvisor < Alternative::Source

  def self.agency_name
    "Tripadvisor"
  end

  def ta_id
    agency_id
  end

end
