class Base64Document < ApplicationRecord
  belongs_to :base64_doc_attachable, polymorphic: true

  mount_base64_uploader :file, DocumentUploader
end
