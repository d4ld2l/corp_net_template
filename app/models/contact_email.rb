class ContactEmail < ApplicationRecord
  belongs_to :contactable, polymorphic: true

  enum kind: [:personal, :work, :other]
end
