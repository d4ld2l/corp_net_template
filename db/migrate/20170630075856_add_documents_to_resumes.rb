class AddDocumentsToResumes < ActiveRecord::Migration[5.0]
  def change
    add_column :resumes, :documents, :json
  end
end
