class CreateResumeExperiences < ActiveRecord::Migration[5.0]
  def change
    create_table :resume_experiences do |t|
      t.integer :company_id
      t.string :position, :limit => 100
      t.date :start_date
      t.date :end_date
      t.string :tasks, :limit => 500
      t.integer :resume_id
      
      t.timestamps
    end
  end
end
