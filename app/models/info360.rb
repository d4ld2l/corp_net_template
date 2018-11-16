class Info360 < ApplicationRecord
  belongs_to :candidate
  # GitHub
  has_one :info360_source_github, dependent: :destroy
end
