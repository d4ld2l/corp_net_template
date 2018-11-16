# Участники встречи(для представительских расходов)
class Participant < ApplicationRecord
  enum type_of_participant: {
    manager_belong_to_company: 1,
    belong_to_company: 2
  }

  belongs_to :account
  belongs_to :information_about_participant

  validates_presence_of :account_id
end
