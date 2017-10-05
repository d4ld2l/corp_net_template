class Topic < ApplicationRecord
  belongs_to :community
  has_many :messages, dependent: :destroy

  mount_uploader :photo, PhotoUploader
end
