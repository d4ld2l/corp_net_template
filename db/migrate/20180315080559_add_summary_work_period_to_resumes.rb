class AddSummaryWorkPeriodToResumes < ActiveRecord::Migration[5.0]
  def change
    add_column :resumes, :summary_work_period, :integer, default: 0
  end
end
