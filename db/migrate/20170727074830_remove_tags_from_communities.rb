class RemoveTagsFromCommunities < ActiveRecord::Migration[5.0]
  def change
    remove_column :communities, :tags, :json
    remove_column :news_items, :tags, :json
  end
end
