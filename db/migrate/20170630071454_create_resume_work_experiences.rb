class CreateResumeWorkExperiences < ActiveRecord::Migration[5.0]
  def change
    create_table :resume_work_experiences do |t|
      t.belongs_to :resume, foreign_key: true
      t.string :position
      t.string :company_name
      t.string :region
      t.string :website
      t.date :start_date
      t.date :end_date
      t.text :experience_description

      t.timestamps
    end
  end
end
