class AccountAchievement < ApplicationRecord
  belongs_to :account
  belongs_to :achievement
end
