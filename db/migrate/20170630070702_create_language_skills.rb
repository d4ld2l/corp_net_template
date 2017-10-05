class CreateLanguageSkills < ActiveRecord::Migration[5.0]
  def change
    create_table :language_skills do |t|
      t.belongs_to :resume, foreign_key: true
      t.belongs_to :language, foreign_key: true
      t.belongs_to :language_level, foreign_key: true

      t.timestamps
    end
  end
end
