class AddAttachmentToMedium < ActiveRecord::Migration
  def change
    add_attachment :media, :file
  end
end
