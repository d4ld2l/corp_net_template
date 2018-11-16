class CreateResumeQualifications < ActiveRecord::Migration[5.0]
  def change
    create_table :resume_qualifications do |t|
      t.string :name
      t.string :company_name
      t.string :speciality
      t.belongs_to :resume, foreign_key: true
      t.string :end_year
      t.string :file

      t.timestamps
    end
  end
end
