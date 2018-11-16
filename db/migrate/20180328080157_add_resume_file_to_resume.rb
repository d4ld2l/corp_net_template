class AddResumeFileToResume < ActiveRecord::Migration[5.0]
  def change
    add_column :resumes, :resume_file, :string
  end
end
