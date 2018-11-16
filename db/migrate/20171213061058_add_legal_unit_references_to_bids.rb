class AddLegalUnitReferencesToBids < ActiveRecord::Migration[5.0]
  def change
    add_reference :bids, :legal_unit, foreign_key: true
  end
end
