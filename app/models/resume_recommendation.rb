class ResumeRecommendation < ApplicationRecord
  belongs_to :resume, touch: true
end
