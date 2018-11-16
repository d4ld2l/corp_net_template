class AddSigninPictureToUiSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :ui_settings, :signin_picture, :string, null: false, default:''
  end
end
