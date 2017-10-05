class AddSpecializationReferenceToResumes < ActiveRecord::Migration[5.0]
  def change
    add_reference :resumes, :professional_specialization, index: true
  end
end
