class AddProcessDescriptionToServices < ActiveRecord::Migration[5.0]
  def change
    add_column :services, :process_description, :text
    add_column :services, :is_bid_required, :boolean
  end
end
