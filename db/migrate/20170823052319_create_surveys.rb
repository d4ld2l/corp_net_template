class CreateSurveys < ActiveRecord::Migration[5.0]
  def change
    create_table :surveys do |t|
      t.string :name
      t.string :symbol
      t.string :state
      t.string :document
      t.text :note
      t.integer :survey_type
      t.boolean :anonymous, default: false
      t.belongs_to :creator, foreign_key: { to_table: :users }
      t.belongs_to :editor, foreign_key: { to_table: :users }
      t.belongs_to :publisher, foreign_key: { to_table: :users }
      t.belongs_to :unpublisher, foreign_key: { to_table: :users }
      t.datetime :published_at
      t.datetime :unpublished_at
      t.date :ends_at

      # temporary
      t.string :background, default: '#ffffff'

      t.timestamps
    end
  end
end
