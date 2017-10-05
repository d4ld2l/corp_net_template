class CreateResumeEducations < ActiveRecord::Migration[5.0]
  def change
    create_table :resume_educations do |t|
      t.belongs_to :education_level, foreign_key: true
      t.string :school_name
      t.string :faculty_name
      t.string :speciality
      t.integer :end_year

      t.timestamps
    end
  end
end
