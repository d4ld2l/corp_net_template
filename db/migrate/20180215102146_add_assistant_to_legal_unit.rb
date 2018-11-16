class AddAssistantToLegalUnit < ActiveRecord::Migration[5.0]
  def change
    add_column :legal_units, :assistant_id, :integer, index: true
    add_foreign_key :legal_units, :users, column: :assistant_id
  end
end
