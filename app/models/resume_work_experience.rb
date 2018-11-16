class ResumeWorkExperience < ApplicationRecord
  belongs_to :resume, touch: true

  def work_period
    if start_date
      end_date = Date.today unless end_date.present?
      (end_date.month+end_date.year*12) - (start_date.month+start_date.year*12)
    else
      0
    end
  end
end
