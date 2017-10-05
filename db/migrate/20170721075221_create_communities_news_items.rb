class CreateCommunitiesNewsItems < ActiveRecord::Migration[5.0]
  def change
    create_table :communities_news_items do |t|
      t.belongs_to :community, foreign_key: true
      t.belongs_to :news_item, foreign_key: true

      t.timestamps
    end
  end
end
