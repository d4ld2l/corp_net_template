class AddResumeSourceAndSourceUpdatedAtIdToResumes < ActiveRecord::Migration[5.0]
  def change
    add_column :resumes, :source_id, :string
    add_column :resumes, :source_updated_at, :date
  end
end
