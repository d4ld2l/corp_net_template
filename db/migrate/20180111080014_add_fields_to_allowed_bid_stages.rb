class AddFieldsToAllowedBidStages < ActiveRecord::Migration[5.0]
  def change
    add_reference :allowed_bid_stages, :executor, foreign_key: { to_table: :bids_executors }
    add_column :allowed_bid_stages, :notification, :boolean
  end
end