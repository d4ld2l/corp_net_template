class CreateConfirmSkills < ActiveRecord::Migration[5.0]
  def change
    create_table :confirm_skills do |t|
      t.integer :resume_skill_id
      t.integer :user_id

      t.timestamps
    end
  end
end
