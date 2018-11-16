class AddCurrentAccountPhotoIdToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :current_account_photo_id, :integer
  end
end
