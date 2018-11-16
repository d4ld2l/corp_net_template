class AddWorkPeriodRequestExpirationDateToResumes < ActiveRecord::Migration[5.0]
  def change
    add_column :resumes, :work_period_request_expiration_date, :date, default: Date.current
    rename_column :resumes, :summary_work_period, :last_requested_work_period
  end
end
