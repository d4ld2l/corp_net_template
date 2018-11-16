class ResumeCourse < ApplicationRecord
  belongs_to :resume, touch: true

  has_one :document, as: :document_attachable, dependent: :destroy
  accepts_nested_attributes_for :document, reject_if: :all_blank, allow_destroy: true

  mount_uploader :file, DocumentUploader
  mount_base64_uploader :file, DocumentUploader
end
