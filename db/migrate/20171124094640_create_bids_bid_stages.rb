class CreateBidsBidStages < ActiveRecord::Migration[5.0]
  def change
    create_table :bids_bid_stages do |t|
      t.references :bid, foreign_key: { on_delete: :cascade }
      t.references :bid_stage, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
