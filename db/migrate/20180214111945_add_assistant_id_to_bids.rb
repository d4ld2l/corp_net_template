class AddAssistantIdToBids < ActiveRecord::Migration[5.0]
  def change
    add_column :bids, :assistant_id, :integer, index: true
    add_column :allowed_bid_stages, :notifiable, :json
    add_foreign_key :bids, :users, column: :assistant_id
  end
end
