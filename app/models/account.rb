class Account < ApplicationRecord
  include AASM
  include Elasticsearch::Model
  include Indexable
  include Accounts::Search
  include Accounts::Associations
  include Accounts::Fullness
  include Accounts::Achievements
  include Accounts::Parser
  include ProjectHierarchable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :omniauthable, authentication_keys: { login: false, email: false }
  include DeviseTokenAuth::Concerns::User

  acts_as_tenant :company

  enum sex: %i[male female], _suffix: true
  enum marital_status: %i[single married divorced widowed]
  validates_numericality_of :kids, greater_than_or_equal_to: 0

  attr_accessor :skip_callbacks
  scope :not_admins, -> { left_outer_joins(:roles).where.not(roles: { name: ['admin', 'supervisor'] }).distinct }
  scope :default_order, -> { order(surname: :asc).order(name: :asc).order(middlename: :asc) }
  scope :not_blocked, -> { where(status: 'active') }
  scope :blocked, -> { where(status: 'blocked') }
  scope :by_lue, ->(ids) { includes(:all_legal_unit_employees).where(legal_unit_employees: { legal_unit_id: ids }).references(:legal_unit_employees) }
  scope :only_with_legal_unit, ->{ joins(:all_legal_unit_employees).distinct }

  mount_uploader :photo, PhotoUploader

  before_save :remove_blank_social_urls
  before_save :set_updater

  before_validation do
    self.uid = email if uid.blank?
    self.login = email.split('@').first if login.nil?
    self.updater = nil if updater && updater.company_id != company_id
  end

  after_create :confirm_user
  # after_create :set_default_role
  after_save :set_default_role

  validates :login, presence: true
  validates_uniqueness_to_tenant :login

  FI_FORMAT = { with: /\A([A-Za-zА-яЁё]+-)*([А-яA-Za-zЁё]+)\z/, message: 'может содержать только буквы и дефис' }.freeze
  MIDDLENAME_FORMAT = { with: /((\A(([A-Za-zА-яЁё]+-)*([А-яA-Za-zЁё]+))\z)|(\A\z))/, message: 'может содержать только буквы и дефис' }.freeze
  validates :name, :surname, presence: true, format: FI_FORMAT
  validates :middlename, format: MIDDLENAME_FORMAT
  validates :birthday, presence: true
  validate :validate_time_zone
  validates_uniqueness_to_tenant :email

  after_save do
    if account_emails.where(preferable: true).size > 1
      errors.add(:account_emails, 'Может быть только один приоритетный вид связи для e-mail')
      account_emails.map { |x| x.errors.add(:preferable, 'Может быть только один приоритетный вид связи для e-mail') }
    end
    if account_phones.where(preferable: true).size > 1
      errors.add(:account_phones, 'Может быть только один приоритетный вид связи для телефонов')
      account_phones.map { |x| x.errors.add(:preferable, 'Может быть только один приоритетный вид связи для телефонов') }
    end
    raise ActiveRecord::RecordInvalid, self unless [errors[:account_phones], errors[:account_emails]].flatten.blank?
  end

  after_update :send_user_notification

  aasm column: :status do
    state :active, initial: true
    state :blocked

    event :to_blocked do
      transitions from: :active, to: :blocked
    end

    event :to_active do
      transitions from: :blocked, to: :active
    end
  end

  def self.create_new_user_by_invite_email(email)
    password = Devise.friendly_token.first(8)
    account = Account.create(email: email.email, password: password, name: email.name, surname: email.surname, middlename: email.middle_name)
    tokens = account.create_new_auth_token
    { account: account, token: tokens }
  end

  def phone
    res = preferred_phone&.number
    res = account_phones&.first&.number unless res&.present?
    res = default_legal_unit_employee&.phone_work unless res&.present?
    res = default_legal_unit_employee&.phone_corporate unless res&.present?
    res if res&.present?
  end

  def email_address
    res = preferred_email&.email
    res = account_emails&.first&.email unless res&.present?
    res = default_legal_unit_employee&.email_work unless res&.present?
    res = default_legal_unit_employee&.email_corporate unless res&.present?
    res = email unless res&.present?
    res if res&.present?
  end

  def telegram
    account_messengers&.find_by(name: 'Telegram')&.phones&.first || account_phones&.find_by(telegram: true, preferable: true)&.number || account_phones&.find_by(telegram: true)&.number&.first
  end

  def should_index?
    active?
  end

  def age
    ((Time.current - birthday.to_time) / 1.year).floor unless birthday.nil?
  end

  def full_name
    full_name = "#{surname} #{name} #{middlename || ''}"
    full_name.present? ? full_name : email
  end

  def surname_with_firstname
    surname_with_firstname = "#{surname} #{name}"
    surname_with_firstname.present? ? surname_with_firstname : email
  end

  def name_surname
    name_surname = [name, surname].compact.join ' '
    name_surname.present? ? name_surname : email
  end

  def full_name_through_dots
    "#{surname} #{name&.at(0)}. #{middlename&.at(0)}."
  end

  def position_name
    default_legal_unit_employee&.position_name
  end

  def managers_chain
    subordination_chain.map { |x| Account.find(x).as_json(methods: %i[subordinates_count position_name]) }.reverse
  end

  def subordinates_list
    subordinates.as_json(methods: %i[subordinates_count position_name])
  end

  def has_permission?(p_name)
    permissions.where(name: p_name).any?
  end

  def role?(role_name)
    roles.where(name: role_name)&.any?
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if key = conditions.delete(:login)
      where(conditions.to_h).where(['lower(login) LIKE ? OR lower(email) LIKE ?', key, key]).first
    elsif key = conditions.delete(:email)
      where(conditions.to_h).where(['lower(login) LIKE ? OR lower(email) LIKE ?', key, key]).first
    end
  end

  def has_ds_roles?
    role?('user') || role?('admin')
  end

  def supervisor?
    permissions.where(name: :supervisor).present?
  end

  def send_notification(type)
    kafka_connector = Kafka::Connector.new('users')
    kafka_connector.send([JSON.dump(to_notification_hash)], type)
  rescue StandardError
    nil # TODO: Add error logging
  end

  def skills_list
    skills.map(&:name)
  end

  def to_notification_hash
    {
      email: email,
      status: status,
      full_name: full_name,
      login: login,
      roles: roles.select { |x| x.name.in?(%w[user admin]) }.map(&:name),
      position: position_name,
      legal_unit_name: default_legal_unit_employee&.legal_unit&.name,
      avatar_url: photo&.url,
      remote_id: id
    }
  end

  private

  def confirm_user
    confirm unless confirmed?
  end

  def set_updater
    u = RequestStore.store[:current_account]
    self.updater = u if u && u.company_id == company_id && valid?
  end

  def remove_blank_social_urls
    social_urls.reject!(&:blank?)
  end

  def send_user_notification
    send_notification('update') if !@skip_callbacks && has_ds_roles?
  end

  def set_default_role
    roles << Role.find_by_name(:user) if roles.empty?
  end

  def validate_time_zone
    errors.add(:time_zone, 'Invalid timezone') unless ActiveSupport::TimeZone.all.map(&:name).include?(time_zone)
  end
end
