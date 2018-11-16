class CreateProjectWorkPeriods < ActiveRecord::Migration[5.0]
  def change
    create_table :project_work_periods do |t|
      t.references :profile_project, foreign_key: true
      t.date :begin_date
      t.date :end_date
      t.string :role
      t.string :duties

      t.timestamps
    end
  end
end
