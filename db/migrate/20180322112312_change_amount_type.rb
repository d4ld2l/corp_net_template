class ChangeAmountType < ActiveRecord::Migration[5.0]
  def change
    change_column :meeting_informations, :amount, 'float USING amount::double precision'
  end
end
