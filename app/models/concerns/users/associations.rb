module Users
  module Associations
    extend ActiveSupport::Concern

    included do
      belongs_to :company
      # has_many :resumes, dependent: :destroy, inverse_of: :user
      has_many :news_items, dependent: :destroy
      has_many :confirm_skills, dependent: :destroy
      # has_many :profile_projects, dependent: :destroy
      # has_many :projects, through: :profile_projects
      has_one :profile, dependent: :destroy, validate: false
      has_many :role_users, dependent: :destroy
      has_many :roles, through: :role_users
      has_many :permissions, -> { distinct }, through: :roles
      has_many :users_vacancies, dependent: :destroy
      has_many :vacancies, through: :users_vacancies
      has_many :communities_users, dependent: :destroy
      has_many :communities, through: :communities_users, dependent: :destroy
      has_many :notifications, dependent: :destroy
      has_many :messages, dependent: :destroy
      has_many :comments, dependent: :destroy
      has_many :vacancy_stage_subscriptions, dependent: :destroy, foreign_key: :user_id
      has_many :vacancy_stages, through: :vacancy_stage_subscriptions
      has_many :survey_result, dependent: :destroy
      has_many :bids, foreign_key: :author_id
      has_many :ahoy_visits, class_name: "Ahoy::Visit"

      delegate :photo, to: :profile, allow_nil: true
      delegate :full_name_through_dots, to: :profile, allow_nil: true
      delegate :position_name, to: :profile

      accepts_nested_attributes_for :profile

      alias_attribute :user_id, :id
    end
  end
end