class CreateBids < ActiveRecord::Migration[5.0]
  def change
    create_table :bids do |t|
      t.references :service, foreign_key: { on_delete: :cascade }
      t.references :author, foreign_key: { to_table: :users }
      t.references :manager, foreign_key: { to_table: :users }
      t.string :manager_position

      t.timestamps
    end
  end
end
