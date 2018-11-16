class AddUserToVacancies < ActiveRecord::Migration[5.0]
  def change
    add_column :vacancies, :manager_id, :integer
  end
end
