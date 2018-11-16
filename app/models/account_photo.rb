class AccountPhoto < ApplicationRecord

  include LikableModel

  belongs_to :account

  before_save :ensure_crop_info_not_nil
  after_save :ensure_account_has_an_avatar
  before_destroy :ensure_account_avatar_removed

  mount_uploader :photo, AccountPhotoUploader
  mount_base64_uploader :photo, AccountPhotoUploader
  mount_uploader :cropped_photo, AccountPhotoUploader
  mount_base64_uploader :cropped_photo, AccountPhotoUploader

  def ensure_account_has_an_avatar
    unless cropped_photo.file.nil?
      account.photo.store!(self.cropped_photo.file)
    else
      account.photo.store!(self.photo.file)
    end
    account.current_account_photo_id = id
    account.save!
  end

  def ensure_crop_info_not_nil
    self.crop_info ||= {
        x: 0, y:0, width:0, height: 0
    }.as_json
  end

  def ensure_account_avatar_removed
    if account.current_account_photo_id == id
      account.current_account_photo_id = nil
      account.remove_photo!
      account.save!
    end
  end

  def as_json(current_account_id=nil)
    if current_account_id.present?
      super.merge!("already_liked" => already_liked?(current_account_id))
    else
      super
    end
  end

end
