class AddSpecializationToResumes < ActiveRecord::Migration[5.0]
  def change
    add_column :resumes, :specialization, :string
  end
end
