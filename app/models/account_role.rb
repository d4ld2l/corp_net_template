class AccountRole < ApplicationRecord
  belongs_to :role
  belongs_to :account

  validate do
    if role.permissions.where(name: :supervisor).present? && !RequestStore[:current_account]&.supervisor?
      errors.add(:role_id, 'Роль с функцией `supervisor` может установить только другой supervisor')
    end
  end
end
