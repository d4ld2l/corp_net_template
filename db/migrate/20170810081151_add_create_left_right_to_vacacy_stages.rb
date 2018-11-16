class AddCreateLeftRightToVacacyStages < ActiveRecord::Migration[5.0]
  def change
    add_column :vacancy_stages, :can_create_left, :boolean, default: true
    add_column :vacancy_stages, :can_create_right, :boolean, default: true
  end
end
