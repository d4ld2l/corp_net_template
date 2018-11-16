class CreateByodInformations < ActiveRecord::Migration[5.0]
  def change
    create_table :byod_informations do |t|
      t.references :bid, foreign_key: true
      t.integer :byod_type
      t.string :device_model
      t.string :device_inventory_number
      t.float :compensation_amount

      t.timestamps
    end
  end
end
