class CreateAccountReadingEntities < ActiveRecord::Migration[5.2]
  def change
    create_table :account_reading_entities do |t|
      t.references :account, foreign_key: true
      t.references :readable, polymorphic: true
      t.datetime :last_read_at

      t.timestamps
    end
  end
end
