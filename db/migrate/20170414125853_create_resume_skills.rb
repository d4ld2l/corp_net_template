class CreateResumeSkills < ActiveRecord::Migration[5.0]
  def change
    create_table :resume_skills do |t|
      t.integer :resume_id
      t.integer :skill_id

      t.timestamps
    end
  end
end
