# Юридические лица
class LegalUnit < ApplicationRecord
  acts_as_tenant :company

  has_many :legal_unit_employees, dependent: :destroy
  has_many :accounts, through: :legal_unit_employees
  has_many :departments, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :position_groups, dependent: :destroy
  has_many :positions, dependent: :destroy
  belongs_to :assistant, class_name: 'Account', foreign_key: :assistant_id

  accepts_nested_attributes_for :legal_unit_employees, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :accounts, reject_if: :all_blank, allow_destroy: true

  mount_uploader :logo, DepartmentsPhotoUploader

  validates :name, presence: true
  # :full_name, :legal_address, :inn_number, :kpp_number, :ogrn_number, :city, :general_director,
end
