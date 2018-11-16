class Info360SourceGithub < ApplicationRecord
  belongs_to :info360
  has_many :info360_source_github_repositories, dependent: :destroy
end
