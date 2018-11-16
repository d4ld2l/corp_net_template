class RenameProfileAchievementIdToAccounAchievementIdInTransactions < ActiveRecord::Migration[5.2]
  def change
    rename_column :transactions, :profile_achievement_id, :account_achievement_id
  end
end
