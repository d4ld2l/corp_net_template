class CreateParticipants < ActiveRecord::Migration[5.0]
  def change
    create_table :participants do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :information_about_participant, foreign_key: true
      t.string :position
      t.integer :type_of_participant
      t.string :name

      t.timestamps
    end
  end
end
