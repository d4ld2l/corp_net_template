class AddFieldsToVacancy < ActiveRecord::Migration[5.0]
  def change
    add_column :vacancies, :legal_unit, :string
    add_column :vacancies, :block, :string
    add_column :vacancies, :practice, :string
    add_column :vacancies, :project, :string
    remove_column :vacancies, :job_subdivision, :text
  end
end
