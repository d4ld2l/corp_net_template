class AddCompanyIdToVacancyStages < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancy_stages, :company_id, :integer, index: true
  end
end
