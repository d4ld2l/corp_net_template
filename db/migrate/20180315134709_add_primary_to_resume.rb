class AddPrimaryToResume < ActiveRecord::Migration[5.0]
  def up
    add_column :resumes, :primary, :boolean, default: true, null: false
  end

  def down
    remove_column :resumes, :primary
  end

  def data
    # Resume.where.not(candidate_id: nil).update_all(primary: true)
  end
end
