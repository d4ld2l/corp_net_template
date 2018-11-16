class AddCreatedByToBids < ActiveRecord::Migration[5.0]
  def change
    add_column :bids, :created_by_id, :integer, index: true
  end
end
