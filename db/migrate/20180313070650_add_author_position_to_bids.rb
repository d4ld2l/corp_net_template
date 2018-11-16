class AddAuthorPositionToBids < ActiveRecord::Migration[5.0]
  def change
    add_column :bids, :author_position, :string
  end
end
