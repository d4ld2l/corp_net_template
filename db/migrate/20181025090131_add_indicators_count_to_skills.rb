class AddIndicatorsCountToSkills < ActiveRecord::Migration[5.2]
  def change
    add_column :skills, :indicators_count, :integer, default: 0, null: false
  end
end
