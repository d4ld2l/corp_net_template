class CreateProfessionalAreas < ActiveRecord::Migration[5.0]
  def change
    create_table :professional_areas do |t|
      t.string :name

      t.timestamps
    end
  end
end
