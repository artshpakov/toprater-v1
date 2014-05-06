class Medium::Solvertour < Medium

  def self.agency_name
    "Solvertour"
  end

  def self.agency_url
    "http://solvertour.ru"
  end

  def media_host
    "http://img0.solvertour.ru"
  end

  def url(size=:original)
    return file.url(size) if file.exists?
    "#{media_host}#{super()}"
  end

end
