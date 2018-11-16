class AddCanAchieveAgainToAchievements < ActiveRecord::Migration[5.0]
  def change
    add_column :achievements, :can_achieve_again, :boolean, default: false
  end
end
