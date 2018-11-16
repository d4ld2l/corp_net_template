class AddAvailableToAllToSurvey < ActiveRecord::Migration[5.0]
  def change
    add_column :surveys, :available_to_all, :boolean, null: false, default: true
  end
end
