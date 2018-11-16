class ChangeUserToProfileInResume < ActiveRecord::Migration[5.0]
  def up
    rename_column :resumes, :user_id, :profile_id
    add_index :resumes, :profile_id
  end

  def down
    remove_index :resumes, :profile_id
    rename_column :resumes, :profile_id, :user_id
  end
end
