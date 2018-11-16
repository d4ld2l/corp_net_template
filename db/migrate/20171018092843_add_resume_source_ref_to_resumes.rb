class AddResumeSourceRefToResumes < ActiveRecord::Migration[5.0]
  def change
    add_reference :resumes, :resume_source, foreign_key: true
  end
end
