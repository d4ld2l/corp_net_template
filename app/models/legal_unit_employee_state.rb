class LegalUnitEmployeeState < ApplicationRecord
  after_initialize :set_default_state
  validates_presence_of :state
  after_save :reindex_lues_accounts

  has_paper_trail

  def reindex_lues_accounts
    LegalUnitEmployee.where(legal_unit_employee_state_id: id).each do |lue|
      lue.touch
    end
  end

  def set_default_state
    self.state ||= 'Активный'
  end

  def versions_history
    versions.map(&:reify).compact
  end
end
