class CreateTopics < ActiveRecord::Migration[5.0]
  def change
    create_table :topics do |t|
      t.string :subject, limit: 70
      t.string :photo
      t.belongs_to :community, foreign_key: true

      t.timestamps
    end
  end
end
