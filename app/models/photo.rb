class Photo < ApplicationRecord
  belongs_to :photo_attachable, polymorphic: true

  with_options unless: -> { photo_attachable_type == 'Post' } do
    validates_presence_of :name, :file
  end

  with_options if: -> { photo_attachable_type == 'Post' } do
    validates :file, file_size: { less_than: 10.megabytes }
  end


  mount_uploader :file, PhotoUploader
  mount_base64_uploader :file, PhotoUploader
end
