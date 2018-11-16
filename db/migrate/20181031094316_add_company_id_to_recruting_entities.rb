class AddCompanyIdToRecrutingEntities < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :company_id, :integer, index: true
    add_column :permissions, :company_id, :integer, index: true
    add_column :vacancy_stage_groups, :company_id, :integer, index: true
    add_column :languages, :company_id, :integer, index: true
    add_column :language_levels, :company_id, :integer, index: true
    add_column :template_stages, :company_id, :integer, index: true
    add_column :education_levels, :company_id, :integer, index: true
    add_column :professional_areas, :company_id, :integer, index: true
    add_column :professional_specializations, :company_id, :integer, index: true
  end
end
