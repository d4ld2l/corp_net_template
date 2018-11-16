class AddCandidateReferenceToResumes < ActiveRecord::Migration[5.0]
  def change
    add_reference :resumes, :candidate, index: true
  end
end
