class SetDefaultToAccountPhotosLikesCount < ActiveRecord::Migration[5.2]
  def up
    change_column :account_photos, :likes_count, :integer, default: 0
  end

  def down
    change_column :account_photos, :likes_count, :integer, default: nil
  end
end
