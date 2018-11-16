# Группы сервисов
class ServiceGroup < ApplicationRecord
  has_many :services, dependent: :destroy

  acts_as_tenant :company

  mount_uploader :icon, PhotoUploader
  mount_base64_uploader :icon, PhotoUploader
end
