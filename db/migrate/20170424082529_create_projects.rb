class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      t.string :title, :limit => 300
      t.string :description, :limit => 1000
      t.integer :manager
      t.integer :customer_id
      t.date :begin_date
      t.date :end_date
      t.string :status, :limit => 30

      t.timestamps
    end
  end
end
