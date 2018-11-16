# Информация о встрече(для представительских расходов)
class MeetingInformation < ApplicationRecord
  belongs_to :representation_allowance
  has_many :base64_document, as: :base64_doc_attachable, validate: false
  alias_attribute :document, :base64_document
  has_many :check, as: :photo_attachable, class_name: 'Photo', validate: false

  accepts_nested_attributes_for :base64_document, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :check, reject_if: :all_blank, allow_destroy: true

  validates :amount, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :starts_at, :place, :address, :aim, :result, presence: true
end
