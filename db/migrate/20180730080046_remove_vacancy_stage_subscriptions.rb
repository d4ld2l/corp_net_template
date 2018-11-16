class RemoveVacancyStageSubscriptions < ActiveRecord::Migration[5.2]
  def change
    drop_table :vacancy_stage_subscriptions
    drop_table :resume_experiences
    drop_table :project_roles
  end
end
