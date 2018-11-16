class RenameAuthorPositionToCreatedByPosition < ActiveRecord::Migration[5.0]
  def change
    remove_column :bids, :author_position, :string
    remove_column :bids, :created_by_id, :integer, index: true
    add_column :bids, :creator_id, :integer, index: true
    add_column :bids, :creator_position, :string
  end
end
