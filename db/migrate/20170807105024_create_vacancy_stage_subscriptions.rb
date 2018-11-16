class CreateVacancyStageSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :vacancy_stage_subscriptions do |t|
      t.belongs_to :user
      t.belongs_to :vacancy_stage

      t.timestamps
    end
  end
end
