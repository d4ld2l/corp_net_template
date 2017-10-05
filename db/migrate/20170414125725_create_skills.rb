class CreateSkills < ActiveRecord::Migration[5.0]
  def change
    create_table :skills do |t|
      t.string :name, :limit => 50

      t.timestamps
    end
  end
end
