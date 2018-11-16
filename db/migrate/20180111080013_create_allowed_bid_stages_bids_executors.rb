class CreateAllowedBidStagesBidsExecutors < ActiveRecord::Migration[5.0]
  def change
    create_table :allowed_bid_stages_bids_executors do |t|
      t.belongs_to :bids_executor, foreign_key: true
      t.belongs_to :allowed_bid_stage, foreign_key: true

      t.timestamps
    end
  end
end
