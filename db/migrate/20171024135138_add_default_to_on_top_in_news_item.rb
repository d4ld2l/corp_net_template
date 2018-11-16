class AddDefaultToOnTopInNewsItem < ActiveRecord::Migration[5.0]
  def up
    change_column :news_items, :on_top, :boolean, null: false, default: false
  end

  def down
    change_column :news_items, :on_top, :boolean, null: true
  end
end
