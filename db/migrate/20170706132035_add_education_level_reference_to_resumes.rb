class AddEducationLevelReferenceToResumes < ActiveRecord::Migration[5.0]
  def change
    add_reference :resumes, :education_level, index: true
    remove_column :resume_educations, :education_level_id
  end
end
