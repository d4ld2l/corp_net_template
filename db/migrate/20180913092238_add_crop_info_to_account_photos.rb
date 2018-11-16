class AddCropInfoToAccountPhotos < ActiveRecord::Migration[5.2]
  def change
    add_column :account_photos, :crop_info, :jsonb
  end
end
