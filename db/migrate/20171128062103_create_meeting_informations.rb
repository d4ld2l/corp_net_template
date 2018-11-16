class CreateMeetingInformations < ActiveRecord::Migration[5.0]
  def change
    create_table :meeting_informations do |t|
      t.references :representation_allowance, foreign_key: { on_delete: :cascade }
      t.datetime :starts_at
      t.string :place
      t.string :address
      t.text :aim
      t.text :result
      t.string :amount

      t.timestamps
    end
  end
end
