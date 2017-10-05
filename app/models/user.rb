class User < ApplicationRecord
  include DeviseTokenAuth::Concerns::User
  include User::Associations

  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable, :omniauthable

  searchkick callbacks: :async, word_start: [:email, :name, :surname, :middlename,
                                             :full_name, :email_private, :email_work,
                                             :email_corporate, :phone_private, :phone_work,
                                             :phone_corporate, :position_name], merge_mappings: true

  scope :search_import, -> { includes(:profile).not_admins.only_with_profile }
  scope :only_with_profile, -> {includes(:profile).where.not(profiles: {user_id: nil})}
  scope :not_admins, -> {includes(:role).where.not(roles: {name: 'admin'})}

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
      profile_id: profile.id,
      email: email,
      name: profile&.name,
      surname: profile&.surname,
      middlename: profile&.middlename,
      full_name: full_name,
      position: profile&.default_legal_unit_employee&.legal_unit_employee_position&.position&.name_ru, #TODO: delete, deprecated
      email_private: profile&.email_private,
      email_corporate: profile&.default_legal_unit_employee&.email_corporate,
      email_work: profile&.default_legal_unit_employee&.email_work,
      phone_private: profile&.phone_number_private,
      phone_corporate: profile&.default_legal_unit_employee&.phone_corporate,
      phone_work: profile&.default_legal_unit_employee&.phone_work,
      departments_chain: profile.departments_chain,
      position_name: profile&.default_legal_unit_employee&.legal_unit_employee_position&.position&.name_ru,
      photo: profile&.photo
    }
  end
  
  before_validation do
    self.uid = email if uid.blank?
    # self.role = Role.first #temp
  end

  after_create :confirm_user
  after_create :set_default_role

  def confirm_user
    self.confirm
  end

  def role?(role_name)
    role_name.to_s == role.name
  end

  def set_default_role
    self.role ||= Role.find_by_name(:user)
    save!
  end

  def full_name
    self.profile&.full_name || ''
  end
end