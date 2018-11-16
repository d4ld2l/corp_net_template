class CreateSkillConfirmations < ActiveRecord::Migration[5.0]
  def change
    create_table :skill_confirmations do |t|
      t.references :profile, foreign_key: true
      t.references :skill, foreign_key: true

      t.timestamps
    end
  end
end
