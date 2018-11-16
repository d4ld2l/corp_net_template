# Настройки UI
class UiSetting < ApplicationRecord
  belongs_to :company
  acts_as_tenant :company

  mount_uploader :main_logo, UiSettingsUploader
  mount_uploader :signin_logo, UiSettingsUploader
  mount_uploader :signin_animation, UiSettingsUploader
  mount_uploader :main_page_picture, UiSettingsUploader
  mount_uploader :signin_picture, UiSettingsUploader
end
