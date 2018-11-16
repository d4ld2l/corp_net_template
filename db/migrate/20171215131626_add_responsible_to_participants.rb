class AddResponsibleToParticipants < ActiveRecord::Migration[5.0]
  def change
    add_column :participants, :responsible, :boolean
  end
end
