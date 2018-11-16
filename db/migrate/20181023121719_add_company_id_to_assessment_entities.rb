class AddCompanyIdToAssessmentEntities < ActiveRecord::Migration[5.2]
  def change
    add_column :assessment_sessions, :company_id, :integer, index: true
  end
end
