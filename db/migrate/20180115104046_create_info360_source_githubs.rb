class CreateInfo360SourceGithubs < ActiveRecord::Migration[5.0]
  def change
    create_table :info360_source_githubs do |t|
      t.references :info360, index: true
      t.string :account_url
      t.datetime :last_events_date
      t.boolean :hire_able

      t.timestamps
    end
  end
end
