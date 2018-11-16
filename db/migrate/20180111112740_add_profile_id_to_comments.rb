class AddProfileIdToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :profile_id, :integer, index: true
  end
end
