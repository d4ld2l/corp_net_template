class Document < ApplicationRecord
  belongs_to :document_attachable, polymorphic: true, touch: true
  belongs_to :uploaded_by, class_name: 'Account', optional: true
  before_save :set_size_and_extension

  delegate :url, to: :file

  with_options unless: -> { document_attachable_type == 'Post' } do
    validates_presence_of :name
  end

  with_options if: -> { document_attachable_type == 'Post' } do
    validates :file, file_size: { less_than: 20.megabytes }
  end

  before_create { self.uploaded_by = RequestStore.store[:current_account] if RequestStore.store[:current_account] && document_attachable_type == 'Resume' }

  mount_uploader :file, DocumentUploader
  mount_base64_uploader :file, DocumentUploader

  private

  def set_size_and_extension
    self.extension = File.extname(file.path) rescue ""
    self.size = File.size(file.path) rescue 0
  end
end
