class Event < ApplicationRecord
  belongs_to :created_by, class_name: User
  belongs_to :event_type
  has_many :event_participants, dependent: :destroy
  has_many :participants, through: :event_participants, primary_key: :user_id, class_name: User
  has_many :documents, as: :document_attachable, dependent: :destroy #class_name: 'Base64Document', as: :base64_doc_attachable,

  accepts_nested_attributes_for :event_participants, allow_destroy: true
  accepts_nested_attributes_for :documents, allow_destroy: true

  validates :name, length:{ maximum:200 }, presence: true
  validates :place, length:{ maximum: 255 }, if: -> { self.place.present? }

  def participants_count
    participants.count
  end
end
