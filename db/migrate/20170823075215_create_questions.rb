class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :questions do |t|
      t.belongs_to :survey, foreign_key: { on_delete: :cascade }
      t.string :image
      t.text :wording
      # for the future
      # t.integer :type
      t.boolean :ban_own_answer, default: false

      t.timestamps
    end
  end
end
