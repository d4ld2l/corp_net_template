class AddAchievementGroupIdRefAchievements < ActiveRecord::Migration[5.0]
  def change
    add_column :achievements, :achievement_group_id, :integer, index: true
  end
end
