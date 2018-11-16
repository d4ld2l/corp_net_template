class AddLikesCountToNewsItems < ActiveRecord::Migration[5.0]
  def change
    add_column :news_items, :likes_count, :integer, default: 0
  end
end
