class CreateIndicators < ActiveRecord::Migration[5.2]
  def change
    create_table :indicators do |t|
      t.string :name
      t.belongs_to :skill, foreign_key: true

      t.timestamps
    end
    add_reference :indicators, :company, index: true
  end
end
