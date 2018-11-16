class RolePermission < ApplicationRecord
  belongs_to :role
  belongs_to :permission

  validate do
    if permission.name == 'supervisor' && !RequestStore[:current_user]&.supervisor?
      errors.add(:permission_id, 'Функцию `supervisor` может установить только supervisor')
    end
  end
end
