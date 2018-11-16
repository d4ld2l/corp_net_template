class ResumeContact < ApplicationRecord
  belongs_to :resume

  enum contact_type: [:phone, :email, :skype]

  validates :value, presence: true
end
