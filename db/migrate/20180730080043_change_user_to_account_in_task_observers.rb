class ChangeUserToAccountInTaskObservers < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :task_observers, :profiles
    rename_column :task_observers, :profile_id, :account_id
  end
end
