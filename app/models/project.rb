class Project < ApplicationRecord
  include AASM
  include Elasticsearch::Model
  include Indexable
  include DiscussableModel
  include TaskableModel

  acts_as_tenant :company

  belongs_to :legal_unit
  belongs_to :department, required: false
  belongs_to :created_by, class_name: 'Account', optional: true
  belongs_to :updated_by, class_name: 'Account', optional: true
  has_many :account_projects, -> { includes(:account).reorder('accounts.surname asc') }, dependent: :destroy, validate: false
  has_many :accounts, through: :account_projects, validate: false
  has_many :customer_projects, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :customers, through: :customer_projects
  belongs_to :manager, foreign_key: :manager_id, class_name: 'Account'
  has_one :mailing_list, as: :importable, dependent: :destroy

  accepts_nested_attributes_for :account_projects, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :customer_projects, allow_destroy: true, reject_if: :all_blank

  attr_accessor :all_employees

  scope :only_active, -> { where(status: 'active') }
  scope :only_closed, -> { where(status: 'closed') }
  scope :as_participant, ->(account_id) { includes(:account_projects).where(account_projects: { account_id: account_id }) }
  scope :as_manager, ->(account_id) { where(manager_id: account_id) }
  scope :available_for, ->(account_id) { left_joins(:account_projects).where('projects.manager_id = ? OR account_projects.account_id = ?', account_id, account_id).distinct }

  after_create :make_all_employees_participated, if: -> { all_employees }
  before_create :set_creator
  before_update :set_updater

  aasm column: :status do
    state :active, initial: true
    state :closed

    event :to_closed do
      transitions from: :active, to: :closed
    end

    event :to_active do
      transitions from: :closed, to: :active
    end
  end

  acts_as_taggable_on :products, :methodologies, :technologies

  validates :title, presence: true, allow_blank: false
  validate :department_belongs_to_correct_legal_unit

  def main_customer
    customers.first
  end

  def to_mailing_list(account)
    self.mailing_list ||= build_mailing_list(name: title, creator: account)
    ml = self.mailing_list
    ml.update_attribute(:name, title)
    ml.accounts = accounts
    ml.touch
    ml
  end

  def accounts_count
    account_projects_count
  end

  def as_indexed_json(options = {})
    # as_json(options.merge(
    #                     only: %i[title description],
    #                     methods: %i[product_list methodology_list technology_list],
    #                     include: { customers: {methods: :full_name}, manager: {methods: :full_name} }
    # ))
    as_json(
        only: %i[title description],
        methods: %i[product_list methodology_list technology_list],
        include: { customers: {only: %i[id name]}, manager: {methods: :full_name, only: %i[id]} }
    )
  end

  def self.search(query, options={})
    __elasticsearch__.search(
        query: {
            bool: {
                must: {
                    multi_match: {
                        query: query,
                        type: 'phrase_prefix',
                        fields: %w[title description manager.full_name customers.name]
                    }
                }
            }
        }
    )
  end

  private

  def make_all_employees_participated
    ActiveRecord::Base.no_touching do
      self.account_projects = Account.not_blocked.not_admins.map{|x| AccountProject.new(account:x)}
    end
  end

  def set_creator
    if RequestStore.store[:current_account]
      self.created_by_id = RequestStore.store[:current_account]&.id
      self.updated_by_id = RequestStore.store[:current_account]&.id
    end
  end

  def set_updater
    self.updated_by_id = RequestStore.store[:current_account]&.id if RequestStore.store[:current_account]
  end

  def department_belongs_to_correct_legal_unit
    errors.add(:department_id, 'Подразделение должно принадлежать выбранному юрлицу') unless department.blank? || department&.legal_unit_id == legal_unit_id
  end
end
