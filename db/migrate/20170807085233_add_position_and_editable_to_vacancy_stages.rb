class AddPositionAndEditableToVacancyStages < ActiveRecord::Migration[5.0]
  def change
    add_column :vacancy_stages, :position, :integer
    add_column :vacancy_stages, :editable, :boolean
    add_column :vacancy_stages, :must_be_last, :boolean
    add_column :vacancy_stages, :name, :string
    remove_column :vacancy_stages, :group_name
    add_column :vacancy_stages, :group_name, :integer
  end
end
