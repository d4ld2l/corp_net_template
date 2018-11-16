class ChangeUserToAccountInResumes < ActiveRecord::Migration[5.2]
  def change
    rename_column :resumes, :profile_id, :account_id
  end
end
