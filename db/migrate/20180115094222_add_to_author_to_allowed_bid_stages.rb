class AddToAuthorToAllowedBidStages < ActiveRecord::Migration[5.0]
  def change
    add_column :allowed_bid_stages, :to_author, :boolean, default: false
  end
end
