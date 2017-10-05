class AdditionalContact < ApplicationRecord
  enum type: [:vk, :linkedin, :github, :facebook, :other]

  belongs_to :resume
end
