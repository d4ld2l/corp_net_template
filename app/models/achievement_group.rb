class AchievementGroup < ApplicationRecord
  has_many :achievements, dependent: :nullify
  validates_presence_of :name
end
