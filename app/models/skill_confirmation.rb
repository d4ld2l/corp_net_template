class SkillConfirmation < ApplicationRecord
  belongs_to :account
  belongs_to :account_skill, counter_cache: true

  validates_uniqueness_of :account_skill_id, scope: [:account_id], message: 'Подтвердить навык можно только один раз', on: :create
end
