class AccountVacancy < ApplicationRecord
  belongs_to :account
  belongs_to :vacancy, touch: true

  after_save {vacancy&.touch}
end
