class AddInitialToBidStages < ActiveRecord::Migration[5.0]
  def change
    add_column :bid_stages, :initial, :boolean, default: false
  end
end
