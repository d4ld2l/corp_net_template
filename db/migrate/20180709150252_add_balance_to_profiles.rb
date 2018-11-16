class AddBalanceToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :balance, :integer, default: 0
  end
end
