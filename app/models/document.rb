class Document < ApplicationRecord
  belongs_to :document_attachable, polymorphic: true

  validates_presence_of :name

  mount_uploader :file, DocumentUploader
  mount_base64_uploader :file, DocumentUploader
end
