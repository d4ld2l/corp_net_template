class ChangeTypeOfPhotoInDepartments < ActiveRecord::Migration[5.0]
  def change
    remove_column :departments, :photo, :json
    add_column :departments, :photo, :string
  end
end
