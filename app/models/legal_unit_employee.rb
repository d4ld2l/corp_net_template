# Привязка сотрудника (profile) к юрлицу
class LegalUnitEmployee < ApplicationRecord
  include LegalUnitEmployees::TransfersHistory

  belongs_to :account, optional: false, validate: false
  belongs_to :legal_unit, optional: false
  belongs_to :manager, class_name: 'Account'
  belongs_to :legal_unit_employee_state, dependent: :destroy
  belongs_to :state, class_name: 'LegalUnitEmployeeState', foreign_key: :legal_unit_employee_state_id, dependent: :destroy
  belongs_to :office
  belongs_to :contract_type, required: false
  has_one :legal_unit_employee_position, dependent: :destroy
  has_one :position, class_name: 'LegalUnitEmployeePosition', dependent: :destroy

  accepts_nested_attributes_for :legal_unit_employee_state, allow_destroy: true
  accepts_nested_attributes_for :legal_unit_employee_position, allow_destroy: true
  accepts_nested_attributes_for :account, allow_destroy: true

  validates_presence_of :legal_unit_id
  validates_associated :legal_unit_employee_state
  validate :only_one_default_legal_unit
  validates_uniqueness_of :account_id, scope: :legal_unit_id
  validates_numericality_of :wage_rate, greater_than: 0, less_than_or_equal_to: 1.0, if: -> { wage_rate }

  after_touch { account.__elasticsearch__.index_document } # для реиндекса аккаунта при изменении;

  has_paper_trail only: %i[wage wage_rate manager_id contract_type_id]

  # def departments_chain
  #   chain = []
  #   x = position&.department
  #   while x
  #     chain << x
  #     x = x&.parent
  #     break if chain.size > 5
  #   end
  #   chain.reverse
  # end

  def departments_chain
    id = position&.department&.id
    return [] unless id
    sql = "WITH RECURSIVE department_children(department_id) AS(
          SELECT d.id AS department_id, d.code, d.parent_id
               FROM departments AS d
               WHERE d.id = #{id}
               UNION
               SELECT d.id AS department_id, d.code, d.parent_id
               FROM departments AS d
               INNER JOIN department_children AS dd ON dd.parent_id = d.id
             ) SELECT departments.* FROM departments WHERE departments.id IN (SELECT department_id FROM department_children)"
    self.class.find_by_sql(sql)
  end

  def department_name
    position&.department&.name_ru
  end

  def legal_unit_name
    legal_unit&.name
  end

  #use only for elastic indexing
  def practice_chain
    departments_chain.reject { |x| x.parent_id.blank? }.map(&:name_ru)
  end

  #use only for elastic indexing
  def block
    departments_chain.keep_if { |x| x.parent_id.blank? }.last&.name_ru
  end

  def position_name
    position&.position_name
  end

  def office_name
    office&.name
  end

  def contract_type_name
    contract_type&.name
  end

  def state_name
    state&.state
  end

  protected

  def only_one_default_legal_unit
    return unless default?
    matches = LegalUnitEmployee.where(default: true, account_id: account_id)
    matches = matches.where('id != ?', id) if persisted?
    errors.add(:default, 'Только одно юр.лицо может быть основным') if matches.exists?
  end
end
