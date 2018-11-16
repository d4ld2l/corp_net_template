class AddCountersToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :participants_passed_count, :integer, null: false, default: 0
    add_column :surveys, :participants_total_count, :integer, null: false, default: 0
    add_column :surveys, :questions_count, :integer, null: false, default: 0
  end
end
