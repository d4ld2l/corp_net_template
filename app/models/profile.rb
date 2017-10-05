class Profile < ApplicationRecord
  include ProjectHierarchable
  delegate :email, to: :user, allow_nil: true

  belongs_to :user
  belongs_to :office
#  belongs_to :manager, class_name: 'Profile', required: false
#  belongs_to :department, primary_key: :code, foreign_key: :department_code, required: false
#  belongs_to :position, primary_key: :code, foreign_key: :position_code

  has_many :legal_unit_employees, -> { where default: false }
  has_one :default_legal_unit_employee,-> { where default: true }, class_name: LegalUnitEmployee, dependent: :destroy

  accepts_nested_attributes_for :default_legal_unit_employee, reject_if: :all_blank
  enum sex: [:male, :female], _suffix: true

  scope :not_admins, -> { joins(user: :role).where.not('users' => {'roles' =>{ 'name' => 'admin' } }) } #TODO: WTF: Tell me why hashes is working here but not colons (new notation)???

  mount_uploader :photo, PhotoUploader

  searchkick callbacks: :async, word_start: [:email, :name, :surname, :middlename], language: [:russian, :english]

  def search_data
    {
        email: email,
        name: name,
        surname: surname,
        middlename: middlename,
        department: default_legal_unit_employee&.legal_unit_employee_position&.department&.name_ru,
        position: default_legal_unit_employee&.legal_unit_employee_position&.position&.name_ru,
        email_work: default_legal_unit_employee&.email_work,
        email_corporate: default_legal_unit_employee&.email_corporate,
        email_private: email_private
    }
  end

  def full_name
    "#{surname} #{name} #{middlename}"
  end

  def position_name
    default_legal_unit_employee&.legal_unit_employee_position&.position&.name_ru
  end

  def managers_chain
    subordination_chain.map{|x| Profile.find(x).as_json({methods:[:subordinates_count, :position_name]})}.reverse
  end

  def subordinates_list
    subordinates.as_json({methods:[:subordinates_count, :position_name]})
  end

  validates :name, :middlename, :surname, presence: true
end
