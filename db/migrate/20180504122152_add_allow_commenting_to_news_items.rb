class AddAllowCommentingToNewsItems < ActiveRecord::Migration[5.0]
  def change
    add_column :news_items, :allow_commenting, :boolean, null: false, default: true
  end
end
