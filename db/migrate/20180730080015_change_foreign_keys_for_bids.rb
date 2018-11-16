class ChangeForeignKeysForBids < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :bids, column: :assistant_id
    remove_foreign_key :bids, column: :author_id
    remove_foreign_key :bids, column: :manager_id
    remove_foreign_key :bids, column: :matching_user_id
  end
end
