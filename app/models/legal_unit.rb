class LegalUnit < ApplicationRecord
  belongs_to :company
  has_many :legal_unit_employees
  has_many :profiles, through: :legal_unit_employees

  accepts_nested_attributes_for :legal_unit_employees, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :profiles, reject_if: :all_blank, allow_destroy: true

  mount_uploader :logo, DepartmentsPhotoUploader

  validates :name, presence: true
end
