class CreateCommunities < ActiveRecord::Migration[5.0]
  def change
    create_table :communities do |t|
      t.string :name
      t.integer :c_type
      t.text :description
      t.json :tags
      t.string :photo
      t.json :documents
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end
