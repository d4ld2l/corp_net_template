class AddExperienceToResumes < ActiveRecord::Migration[5.0]
  def change
    add_column :resumes, :experience, :json
  end
end
