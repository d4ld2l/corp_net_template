class User < ApplicationRecord
  # include RocketChatAuthable
  include Users::Associations
  include Users::Parser
  include AASM
  include DeviseTokenAuth::Concerns::User

  attr_accessor :skip_callbacks

  acts_as_tenant :company

  validates :login, presence: true
  validates_uniqueness_to_tenant :login

  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable, :omniauthable, authentication_keys: {login:false, email:false}

  aasm column: :status do
    state :active, initial: true
    state :blocked

    event :to_blocked, after: :update_index do
      transitions from: :active, to: :blocked
    end

    event :to_active, after: :update_index do
      transitions from: :blocked, to: :active
    end
  end

  before_destroy { CandidateChange.where(user: itself).destroy_all }


  scope :search_import, -> { includes(:profile).only_with_profile.not_blocked }
  scope :only_with_profile, -> { includes(:profile).where.not(profiles: { user_id: nil }) }
  scope :not_admins, -> { includes(:roles).where.not(roles: { name: 'admin' }) }
  scope :default_order, -> { includes(:profile).order('profiles.surname asc').order('profiles.name asc').order('profiles.middlename asc') }
  scope :not_blocked, -> { where(status: 'active') }

  def self.create_new_user_by_invite_email(email)
    password = Devise.friendly_token.first(8)
    user = User.create(email: email.email, password: password)
    tokens = user.create_new_auth_token
    user.build_profile(name: email.name, surname: email.surname, middlename: email.middle_name).save(validate: false)
    { user: user, token: tokens }
  end

  def search_data
    {
      id: id,
      profile_id: profile&.id,
      email: email,
      name: profile&.name,
      surname: profile&.surname,
      middlename: profile&.middlename,
      full_name: full_name,
      position: profile&.default_legal_unit_employee&.legal_unit_employee_position&.position&.name_ru, #TODO: delete, deprecated
      # email_private: profile&.email_private,
      email_corporate: profile&.default_legal_unit_employee&.email_corporate,
      email_work: profile&.default_legal_unit_employee&.email_work,
      # phone_private: profile&.phone_number_private,
      phone_corporate: profile&.default_legal_unit_employee&.phone_corporate,
      phone_work: profile&.default_legal_unit_employee&.phone_work,
      departments_chain: profile&.departments_chain,
      position_name: profile&.default_legal_unit_employee&.legal_unit_employee_position&.position&.name_ru,
      photo: profile&.photo
    }
  end

  before_validation do
    self.uid = email if uid.blank?
    self.login = self.email.split('@').first if self.login.nil?
    # self.role = Role.first #temp
  end

  after_create :confirm_user
  after_create :set_default_role
  before_save :set_default_role

  after_create -> (x) { x.send_notification('create') }, if: ->{!@skip_callbacks && has_ds_roles?}
  after_update -> (x) { x.send_notification('update') }, if: ->{!@skip_callbacks && has_ds_roles?}
  after_touch -> (x) { x.send_notification('update') }, if: ->{!@skip_callbacks && has_ds_roles?}
  before_destroy -> (x) { x.send_notification('delete') }, if: ->{!@skip_callbacks && has_ds_roles?}

  def has_ds_roles?
    role?('user') || role?('admin')
  end

  def supervisor?
    permissions.where(name: :supervisor).present?
  end

  def confirm_user
    self.confirm
  end

  def role?(role_name)
    roles.where(name: role_name)&.any?
  end

  def set_default_role
    if roles.empty?
      self.roles << Role.find_by_name(:user)
      save!
    end
  end

  def full_name
    self.profile&.full_name || ''
  end

  def full_name_through_dots
    self.profile&.full_name_through_dots || email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if key = conditions.delete(:login)
      where(conditions.to_h).where(["lower(login) LIKE ? OR lower(email) LIKE ?", key, key]).first
    elsif key = conditions.delete(:email)
      where(conditions.to_h).where(["lower(login) LIKE ? OR lower(email) LIKE ?", key, key]).first
    end
  end

  def send_notification(type)
    begin
      kafka_connector = Kafka::Connector.new('users')
      kafka_connector.send([JSON.dump(to_notification_hash)], type)
    rescue
      nil #TODO: Add error logging
    end

  end

  def to_notification_hash
    {
      email: email,
      status: status,
      full_name: full_name,
      login: login,
      roles: roles.select { |x| x.name.in?(['user', 'admin']) }.map(&:name),
      position: profile&.position_name,
      legal_unit_name: profile&.default_legal_unit_employee&.legal_unit&.name,
      avatar_url: profile&.photo&.url,
      remote_id: id
    }
  end

  def has_permission?(p_name)
    permissions.where(name: p_name).any?
  end

  # def permissions
  #   includes(roles: :permissions).roles.flat_map{|x| x.permissions}.uniq
  # end
end