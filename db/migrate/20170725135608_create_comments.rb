class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.belongs_to :news_item, foreign_key: true
      t.string :body
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end
