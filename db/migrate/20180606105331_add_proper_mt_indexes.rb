class AddProperMtIndexes < ActiveRecord::Migration[5.0]
  def change
    remove_index :users, :email
    remove_index :users, :login
    remove_index :users, [:uid, :provider]

    add_index :users, [:company_id, :email]
    add_index :users, [:company_id, :login]
  end
end
