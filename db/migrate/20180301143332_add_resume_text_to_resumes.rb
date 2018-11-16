class AddResumeTextToResumes < ActiveRecord::Migration[5.0]
  def change
    add_column :resumes, :resume_text, :string
    add_column :resumes, :parsed, :boolean, default: false
    add_column :resumes, :raw_resume_doc_id, :integer, index: true
  end
end
