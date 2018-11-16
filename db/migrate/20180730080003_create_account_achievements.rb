class CreateAccountAchievements < ActiveRecord::Migration[5.2]
  def change
    create_table :account_achievements do |t|
      t.references :account, foreign_key: true
      t.references :achievement, foreign_key: true

      t.timestamps
    end
  end
end
