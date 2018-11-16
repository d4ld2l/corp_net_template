class CreateAccountProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :account_projects do |t|
      t.references :account, foreign_key: true
      t.references :project, foreign_key: true
      t.text :feedback
      t.integer :rating
      t.integer :worked_hours
      t.string :status
      t.date :gone_date

      t.timestamps
    end
  end
end
