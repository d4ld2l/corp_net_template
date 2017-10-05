class CreateOffices < ActiveRecord::Migration[5.0]
  def change
    create_table :offices do |t|
      t.string :name, :limit => 200

      t.timestamps
    end
  end
end
