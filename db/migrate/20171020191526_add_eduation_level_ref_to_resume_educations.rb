class AddEduationLevelRefToResumeEducations < ActiveRecord::Migration[5.0]
  def change
    add_reference :resume_educations, :education_level
  end
end
