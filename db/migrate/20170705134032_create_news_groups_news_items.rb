class CreateNewsGroupsNewsItems < ActiveRecord::Migration[5.0]
  def change
    create_table :news_groups_news_items do |t|
      t.belongs_to :news_group, foreign_key: true
      t.belongs_to :news_item, foreign_key: true
    end
  end
end