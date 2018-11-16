# Группа настроек тенанта
class SettingsGroup < ApplicationRecord
  belongs_to :company
  has_many :settings

  validates_presence_of :label, :code
  validates_uniqueness_of :code, scope: :company_id

  acts_as_tenant :company
end
