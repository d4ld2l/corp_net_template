class DeletePositionFromResume < ActiveRecord::Migration[5.0]
  def change
    remove_column :resumes, :position, :string
  end
end
