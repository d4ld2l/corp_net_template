class CreateDepartments < ActiveRecord::Migration[5.0]
  def change
    create_table :departments do |t|
      t.references :company, foreign_key: true
      t.string :code
      t.string :name_ru
      t.references :parent, index: true
      t.integer :region

      t.timestamps
    end
  end
end
