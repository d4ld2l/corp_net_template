class ChangeUserToAccountInLegalUnits < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :legal_units, column: :assistant_id
  end
end
