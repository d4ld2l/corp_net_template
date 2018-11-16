# Настройки кластера
class AdminSetting < ApplicationRecord
  validates_presence_of :name, :value, :kind
  enum kind: [:boolean, :string]

  def enabled?
    self.value == '1'
  end
end
