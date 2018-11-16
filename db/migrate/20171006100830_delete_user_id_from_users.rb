class DeleteUserIdFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :role_id, :integer
  end
end
