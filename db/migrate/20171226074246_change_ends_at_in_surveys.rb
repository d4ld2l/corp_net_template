class ChangeEndsAtInSurveys < ActiveRecord::Migration[5.0]
  def up
    change_column :surveys, :ends_at, :datetime
  end

  def down
    change_column :surveys, :ends_at, :date
  end
end
