class CreateOfferedVariants < ActiveRecord::Migration[5.0]
  def change
    create_table :offered_variants do |t|
      t.belongs_to :question, foreign_key: { on_delete: :cascade }
      t.string :wording

      t.timestamps
    end
  end
end
