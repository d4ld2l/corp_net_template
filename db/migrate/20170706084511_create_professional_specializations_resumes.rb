class CreateProfessionalSpecializationsResumes < ActiveRecord::Migration[5.0]
  def change
    create_table :professional_specializations_resumes do |t|
      t.belongs_to :resume, foreign_key: true,
                   index: {name: 'index_professional_specializations_resumes_on_resume_id'}
      t.belongs_to :professional_specialization, foreign_key: true,
                   index: {name: 'index_professional_specializations_resumes_on_prof_spec_id'}
    end
  end
end
