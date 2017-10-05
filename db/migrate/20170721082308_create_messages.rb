class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.text :body
      t.belongs_to :topic, foreign_key: true, index: true
      t.references :parent_message, index: true
      t.references :user, foreign_key: true, index: true

      t.timestamps
    end
  end
end
