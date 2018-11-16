class RemoveUselessFieldsFromResumes < ActiveRecord::Migration[5.0]
  def change
    remove_column :resumes, :phone, :string
    remove_column :resumes, :email, :string
    remove_column :resumes, :skype, :string
    remove_column :resumes, :preferred_contact_type, :integer
  end
end
