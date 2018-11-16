class ByodInformation < ApplicationRecord
  enum byod_type: %i[buy_out new_device]

  belongs_to :bid
  belongs_to :project, optional: true

  has_many :documents, as: :document_attachable, validate: false

  accepts_nested_attributes_for :documents, reject_if: :all_blank, allow_destroy: true

  validates :compensation_amount, numericality: { greater_than_or_equal_to: 0 }, presence: true
end
