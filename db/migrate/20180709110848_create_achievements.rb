class CreateAchievements < ActiveRecord::Migration[5.0]
  def change
    create_table :achievements do |t|
      t.string :name
      t.string :code
      t.string :photo
      t.integer :pay, default: 0
      t.boolean :enabled, default: false

      t.timestamps
    end
  end
end
