class UsersVacancy < ApplicationRecord
  belongs_to :user
  belongs_to :vacancy, touch: true

  after_save {vacancy&.touch}
end
