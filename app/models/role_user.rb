class RoleUser < ApplicationRecord
  belongs_to :role
  belongs_to :user

  validate do
    if role.permissions.where(name: :supervisor).present? && !RequestStore[:current_user]&.supervisor?
      errors.add(:role_id, 'Роль с функцией `supervisor` может установить только другой supervisor')
    end
  end
end
