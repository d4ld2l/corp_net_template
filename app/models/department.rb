class Department < ApplicationRecord
  belongs_to :company, required: false
  belongs_to :parent, class_name: Department, foreign_key: :parent_id, optional: true, required: false
  belongs_to :legal_unit
  belongs_to :manager, class_name: Profile, foreign_key: :manager_id, required: false

  has_many :legal_unit_employee_positions, foreign_key: :department_code, primary_key: :code
  has_many :children, class_name: Department, foreign_key: :parent_id

  scope :top_level, ->{where(parent_id: nil)}
  scope :with_children, ->{includes(:children)}
  scope :with_employees, ->{includes(legal_unit_employee_positions:[legal_unit_employee:[:profile]])}

  searchkick callbacks: :async, word_start: [:name, :code]
  scope :search_import, -> { with_children.with_employees }
  def search_data
    {
        name: name_ru,
        code: code,
        participants: decorate.participants_hash,
        logo: logo.as_json
    }
  end

  mount_uploader :logo, DepartmentsPhotoUploader

  validates :name_ru, :code, presence: true
  validates_uniqueness_of :code, scope: [:legal_unit_id]
end
