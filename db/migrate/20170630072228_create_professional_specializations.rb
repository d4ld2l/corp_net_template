class CreateProfessionalSpecializations < ActiveRecord::Migration[5.0]
  def change
    create_table :professional_specializations do |t|
      t.belongs_to :professional_area, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
