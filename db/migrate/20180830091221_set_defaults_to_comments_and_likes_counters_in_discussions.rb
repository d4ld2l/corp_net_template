class SetDefaultsToCommentsAndLikesCountersInDiscussions < ActiveRecord::Migration[5.2]
  def up
    change_column :discussions, :comments_count, :integer, default: 0
    change_column :discussions, :likes_count, :integer, default: 0
  end

  def down
    change_column :discussions, :comments_count, :integer, default: nil
    change_column :discussions, :likes_count, :integer, default: nil
  end
end
