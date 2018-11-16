module Accounts
  module Associations
    extend ActiveSupport::Concern

    included do
      belongs_to :updater, class_name: 'Account', optional: true

      has_many :ahoy_visits, class_name: 'Ahoy::Visit', dependent: :nullify, foreign_key: :user_id
      has_many :ahoy_events, class_name: 'Ahoy::Event', dependent: :nullify, foreign_key: :user_id

      has_many :account_achievements, dependent: :destroy
      has_many :achievements, through: :account_achievements

      has_many :account_communities, dependent: :destroy
      has_many :communities, through: :account_communities
      has_many :managed_communities, class_name: 'Community', dependent: :nullify

      has_many :account_phones, dependent: :destroy, inverse_of: :account
      accepts_nested_attributes_for :account_phones, reject_if: :all_blank, allow_destroy: true
      has_many :account_messengers, dependent: :destroy, inverse_of: :account
      accepts_nested_attributes_for :account_messengers, reject_if: :all_blank, allow_destroy: true
      has_many :account_emails, dependent: :destroy, inverse_of: :account
      accepts_nested_attributes_for :account_emails, reject_if: :all_blank, allow_destroy: true
      has_one :preferred_phone, -> { where(preferable: true) }, class_name: 'AccountPhone', foreign_key: :account_id, dependent: :destroy
      has_one :preferred_email, -> { where(preferable: true) }, class_name: 'AccountEmail', foreign_key: :account_id, dependent: :destroy

      has_many :account_mailing_lists, inverse_of: :account, dependent: :destroy
      has_many :mailing_lists, through: :account_mailing_lists

      has_many :account_projects, dependent: :destroy, after_add: :check_achievements
      has_many :projects, through: :account_projects

      has_many :account_roles, dependent: :destroy
      has_many :roles, through: :account_roles
      has_many :permissions, -> { distinct }, through: :roles

      has_many :account_vacancies, dependent: :destroy
      has_many :vacancies, through: :account_vacancies

      has_many :bids, foreign_key: :author_id

      has_many :bids_executors, dependent: :destroy

      has_many :candidate_changes, dependent: :nullify

      has_many :candidate_ratings, dependent: :nullify, foreign_key: :commenter_id

      has_many :comments, dependent: :destroy

      has_many :confirm_skills, dependent: :destroy

      has_many :managed_departments, class_name: 'Department', foreign_key: :manager_id

      has_many :discussers, dependent: :destroy
      has_many :discussions, through: :discussers
      has_many :authored_discussions, class_name: 'Discussion', foreign_key: :author_id

      has_many :uploaded_documents, class_name: 'Document', foreign_key: :uploaded_by_id, dependent: :destroy

      has_many :created_events, class_name: 'Event', foreign_key: :created_by_id

      has_many :event_participants, dependent: :destroy, foreign_key: :account_id
      has_many :events, through: :event_participants

      has_many :favorite_discussions, dependent: :destroy
      has_many :discussions_in_favorites, through: :favorite_discussions, class_name: 'Discussion', source: :discussion

      has_many :favorite_posts, dependent: :destroy
      has_many :posts_in_favorites, through: :favorite_posts, class_name: 'Post', source: :post

      has_many :all_legal_unit_employees, -> { order('legal_unit_employees.default DESC NULLS LAST') }, class_name: 'LegalUnitEmployee', dependent: :destroy
      has_many :legal_unit_employees, -> { where default: false }, dependent: :destroy
      has_one :default_legal_unit_employee, -> { where default: true }, class_name: 'LegalUnitEmployee', dependent: :destroy, inverse_of: :account
      accepts_nested_attributes_for :default_legal_unit_employee, reject_if: :all_blank, allow_destroy: true
      has_one :legal_unit, through: :default_legal_unit_employee

      has_many :news_items, dependent: :destroy

      has_many :personal_notifications, dependent: :destroy

      has_many :posts, dependent: :destroy, foreign_key: :author_id

      has_many :managed_projects, foreign_key: :manager_id, dependent: :destroy, class_name: 'Project'

      has_many :resumes, dependent: :destroy, inverse_of: :account, after_add: :check_achievements
      accepts_nested_attributes_for :resumes, reject_if: :all_blank, allow_destroy: true

      has_many :account_skills, -> { order 'skill_confirmations_count desc NULLS LAST' }, dependent: :destroy
      has_many :skills, through: :account_skills
      accepts_nested_attributes_for :account_skills, reject_if: :all_blank, allow_destroy: true
      accepts_nested_attributes_for :skills, reject_if: :all_blank, allow_destroy: true

      has_many :survey_results, dependent: :destroy

      has_many :transactions, foreign_key: :recipient_id

      has_many :account_photos, dependent: :destroy
    end
  end
end