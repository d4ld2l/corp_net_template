class CreateSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :settings do |t|
      t.string :code
      t.string :label
      t.string :value
      t.references :company, index: true

      t.timestamps
    end
  end
end
