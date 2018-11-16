class CreateVacancyStages < ActiveRecord::Migration[5.0]
  def change
    create_table :vacancy_stages do |t|
      t.belongs_to :vacancy
      t.string :group_name
      t.boolean :need_notification
      t.boolean :evaluation_of_candidate
      t.integer :type_of_rating
      t.belongs_to :template_stage

      t.timestamps
    end

    add_column :vacancies, :current_stage_id, :integer, index: true, foreign_key: true
  end
end
