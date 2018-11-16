class ProfileAchievement < ApplicationRecord
  belongs_to :profile
  belongs_to :achievement
end
