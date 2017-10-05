class CreateNewsItems < ActiveRecord::Migration[5.0]
  def change
    create_table :news_items do |t|
      t.belongs_to :news_category, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.string :state
      t.string :title
      t.string :preview
      t.text :body
      t.json :tags
      t.boolean :on_top
      t.datetime :published_at

      t.timestamps
    end
  end
end