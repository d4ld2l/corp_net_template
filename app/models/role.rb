class Role < ApplicationRecord
  has_many :role_functions
  has_many :role_rights
  has_many :account_roles, dependent: :destroy
  has_many :accounts, through: :account_roles
  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions

  accepts_nested_attributes_for :role_permissions, allow_destroy: true

  #acts_as_tenant :company

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
