class CreateCounterparties < ActiveRecord::Migration[5.0]
  def change
    create_table :counterparties do |t|
      t.string :name
      t.string :position
      t.belongs_to :customer, foreign_key: true
      t.boolean :responsible, default: false

      t.timestamps
    end
  end
end
