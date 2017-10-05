class RemoveNewsGroups < ActiveRecord::Migration[5.0]
  def change
    drop_table :news_groups_news_items
    drop_table :news_groups
  end
end
