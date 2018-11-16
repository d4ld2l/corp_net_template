class Permission < ApplicationRecord
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  #acts_as_tenant :company

  validates :name, :description, presence: true
end
