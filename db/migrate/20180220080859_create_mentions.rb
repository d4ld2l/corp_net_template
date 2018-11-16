class CreateMentions < ActiveRecord::Migration[5.0]
  def change
    create_table :mentions do |t|
      t.references :profile, foreign_key: true
      t.references :post, foreign_key: true

      t.timestamps
    end
  end
end
