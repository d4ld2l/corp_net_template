class AddOwnerAndCreatorRefToVacancy < ActiveRecord::Migration[5.0]
  def change
    add_column :vacancies, :owner_id, :integer
    add_column :vacancies, :creator_id, :integer
  end
end
