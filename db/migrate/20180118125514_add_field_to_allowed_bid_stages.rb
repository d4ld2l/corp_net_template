class AddFieldToAllowedBidStages < ActiveRecord::Migration[5.0]
  def change
    add_column :allowed_bid_stages, :to_matching_user, :boolean, default: false
    add_column :allowed_bid_stages, :to_assistant, :boolean, default: false
    add_column :allowed_bid_stages, :name_for_button, :string
  end
end
