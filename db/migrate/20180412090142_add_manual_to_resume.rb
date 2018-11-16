class AddManualToResume < ActiveRecord::Migration[5.0]
  def change
    add_column :resumes, :manual, :boolean, null: false, default: true
  end
end
