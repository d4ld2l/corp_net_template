class CreateServices < ActiveRecord::Migration[5.0]
  def change
    create_table :services do |t|
      t.string :name
      t.string :description
      t.string :state
      t.datetime :published_at
      t.references :service_group, foreign_key: { on_delete: :cascade }
      t.references :bid_stages_group, foreign_key: { on_delete: :cascade }
      t.references :contact, foreign_key: { to_table: :users, on_delete: :nullify }

      t.timestamps
    end
  end
end
