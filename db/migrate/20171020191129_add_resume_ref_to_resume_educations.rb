class AddResumeRefToResumeEducations < ActiveRecord::Migration[5.0]
  def change
    add_reference :resume_educations, :resume
  end
end
