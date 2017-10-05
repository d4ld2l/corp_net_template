class CreateEventParticipants < ActiveRecord::Migration[5.0]
  def change
    create_table :event_participants do |t|
      t.references :event, foreign_key: true
      t.string :email
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
