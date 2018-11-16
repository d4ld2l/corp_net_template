class RemaneCreatedByToCreatedByIdInSessions < ActiveRecord::Migration[5.2]
  def change
    rename_column :assessment_sessions, :created_by, :created_by_id
  end
end
