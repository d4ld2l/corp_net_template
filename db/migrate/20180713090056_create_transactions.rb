class CreateTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :transactions do |t|
      t.integer :kind
      t.string :comment
      t.integer :value, default: 0
      t.references :profile_achievement, index: true
      t.references :recipient, index: true

      t.timestamps
    end
  end
end
