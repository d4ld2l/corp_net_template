class CreateProfileAchievements < ActiveRecord::Migration[5.0]
  def change
    create_table :profile_achievements do |t|
      t.references :profile, foreign_key: true
      t.references :achievement, foreign_key: true

      t.timestamps
    end
  end
end
