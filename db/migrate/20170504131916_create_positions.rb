class CreatePositions < ActiveRecord::Migration[5.0]
  def change
    create_table :positions do |t|
      t.string :code
      t.string :name_ru
      t.text :description
      t.string :position_group_code, index: true
      t.integer :salary_from
      t.integer :salary_up

      t.timestamps
    end
  end
end
