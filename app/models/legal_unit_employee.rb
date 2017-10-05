class LegalUnitEmployee < ApplicationRecord
  include LegalUnitEmployee::TransfersHistory

  belongs_to :profile
  belongs_to :legal_unit
  belongs_to :manager, class_name: Profile
  belongs_to :legal_unit_employee_state
  belongs_to :state, class_name: LegalUnitEmployeeState, foreign_key: :legal_unit_employee_state_id
  belongs_to :office
  belongs_to :contract_type, required: false
  has_one :legal_unit_employee_position, dependent: :destroy
  has_one :position, class_name: LegalUnitEmployeePosition

  accepts_nested_attributes_for :legal_unit_employee_state, allow_destroy: true
  accepts_nested_attributes_for :legal_unit_employee_position, allow_destroy: true
  accepts_nested_attributes_for :profile, allow_destroy: true

  #validates_presence_of :profile_id
  validates_presence_of :legal_unit_id
  validates_associated :legal_unit_employee_state
  validate :only_one_default_legal_unit
  validates_uniqueness_of :profile_id, scope: :legal_unit_id
  validates_numericality_of :wage_rate, greater_than: 0, less_than_or_equal_to: 1.0

  has_paper_trail only: [:pay, :wage_rate, :manager_id, :contract_type_id]

  protected

  def only_one_default_legal_unit
    return unless default?
    matches = LegalUnitEmployee.where(default: true, profile_id: profile_id)
    if persisted?
      matches = matches.where('id != ?', id)
    end
    if matches.exists?
      errors.add(:default, 'Только одно юр.лицо может быть основным')
    end
  end
end
