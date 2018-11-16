class CreateComponents < ActiveRecord::Migration[5.2]
  def change
    create_table :components do |t|
      t.references :company, foreign_key: true
      t.string :name
      t.boolean :enabled, default: true
      t.references :core_component, index: true

      t.timestamps
    end
  end
end
