class CreatePositionGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :position_groups do |t|
      t.string :code
      t.string :name_ru
      t.text :description

      t.timestamps
    end
  end
end
