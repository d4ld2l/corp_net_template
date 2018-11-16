class AddFieldsToAccountPhotos < ActiveRecord::Migration[5.2]
  def change
    add_column :account_photos, :cropped_photo, :string
    add_column :account_photos, :likes_count, :integer
  end
end
