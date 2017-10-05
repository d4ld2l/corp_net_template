class ChangePhotoToLogoInDepartments < ActiveRecord::Migration[5.0]
  def change
    remove_column :departments, :photo, :string
    add_column :departments, :logo, :string
  end
end
