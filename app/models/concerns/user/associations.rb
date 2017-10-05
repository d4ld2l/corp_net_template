module User::Associations
  extend ActiveSupport::Concern

  included do
    has_many :resumes, dependent: :destroy
    has_many :confirm_skills, dependent: :destroy
    has_many :user_projects
    has_many :projects, through: :user_projects
    has_one :profile, dependent: :destroy
    belongs_to :role
    has_many :communities_users, dependent: :destroy
    has_many :communities, through: :communities_users, dependent: :destroy
    has_many :notifications, dependent: :destroy
    has_many :messages, dependent: :destroy
    has_many :comments, dependent: :destroy

    accepts_nested_attributes_for :profile
  end
end
