class AddParticipantsCountToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :participants_count, :integer, default: 0, null: false
  end
end
