class Medium < ActiveRecord::Base
  belongs_to :alternative

  scope :covers, -> { where(cover: true) }

  has_attached_file :file,
    styles: {
      small: "100x100^",
      thumb: "318x200^",
      preview: "1000x500^"},
    convert_options: {
      small: "-gravity center -extent 100x100",
      thumb: "-gravity center -extent 318x200",
      profile: "-gravity center -extent 1000x500"
    }

  validates_attachment_content_type :file, content_type: %w(image/jpeg image/jpg image/png)

  before_post_process :skip_for_non_image

  def skip_for_non_image
    file_content_type.include? "image"
  end

  def file_from_url(url)
    self.file = URI.parse(url)
  end

  def url(size=:original)
    return file.url(size) if file.exists?
    super()
  end

end
