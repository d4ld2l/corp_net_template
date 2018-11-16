class CreateAccountSkills < ActiveRecord::Migration[5.2]
  def change
    create_table :account_skills do |t|
      t.references :account, foreign_key: true
      t.references :skill, foreign_key: true
      t.references :project, index: true
      t.integer :skill_confirmations_count, default: 0
    end
  end
end
