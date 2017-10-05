class CreateLegalUnits < ActiveRecord::Migration[5.0]
  def change
    create_table :legal_units do |t|
      t.string :name
      t.string :code
      t.string :uuid
      t.references :company, foreign_key: true

      t.timestamps
    end
  end
end
