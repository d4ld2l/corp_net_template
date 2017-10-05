class AddCommunityIdToNewsItems < ActiveRecord::Migration[5.0]
  def change
    add_column :news_items, :community_id, :integer, index:true
    drop_table :communities_news_items
  end
end
