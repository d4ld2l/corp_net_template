class CreateCustomerProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :customer_projects do |t|
      t.belongs_to :customer, foreign_key: true
      t.belongs_to :project, foreign_key: true

      t.timestamps
    end
  end
end
