class CreateInfo360s < ActiveRecord::Migration[5.0]
  def change
    create_table :info360s do |t|
      t.references :candidate, index: true

      t.timestamps
    end
  end
end
