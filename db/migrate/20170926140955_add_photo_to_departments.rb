class AddPhotoToDepartments < ActiveRecord::Migration[5.0]
  def change
    add_column :departments, :photo, :json
  end
end
