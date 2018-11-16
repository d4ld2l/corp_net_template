class CreateAllowedBidStages < ActiveRecord::Migration[5.0]
  def change
    create_table :allowed_bid_stages do |t|
      t.references :current_stage, foreign_key: { to_table: :bid_stages, on_delete: :cascade }
      t.references :allowed_stage, foreign_key: { to_table: :bid_stages, on_delete: :cascade }

      t.timestamps
    end
  end
end
