class AddCommentCountersForCommentableClasses < ActiveRecord::Migration[5.0]
  def change
    add_column :news_items, :comments_count, :integer, default: 0
    add_column :bids, :comments_count, :integer, default: 0
  end
end
