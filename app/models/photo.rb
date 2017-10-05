class Photo < ApplicationRecord
  belongs_to :photo_attachable, polymorphic: true

  validates_presence_of :name, :file

  mount_uploader :file, PhotoUploader
end
