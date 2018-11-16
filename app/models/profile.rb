class Profile < ApplicationRecord
  include Profiles::Fullness
  include Profiles::Achievements
  include ProjectHierarchable
  delegate :email, to: :user, allow_nil: true
  # include Elasticsearch::Model
  # include Indexable

  acts_as_tenant :company

  belongs_to :user
  belongs_to :office
  belongs_to :updater, class_name: 'Profile', foreign_key: :updater_id, optional: true

  before_save :remove_blank_social_urls
  before_save :set_updater

  after_save do
    if profile_emails.where(preferable: true).size > 1
      errors.add(:profile_emails, 'Может быть только один приоритетный вид связи для e-mail')
      profile_emails.map{ |x| x.errors.add(:preferable, 'Может быть только один приоритетный вид связи для e-mail') }
    end
    if profile_phones.where(preferable: true).size > 1
      errors.add(:profile_phones, 'Может быть только один приоритетный вид связи для телефонов')
      profile_phones.map{ |x| x.errors.add(:preferable, 'Может быть только один приоритетный вид связи для телефонов') }
    end
    raise ActiveRecord::RecordInvalid.new(self) unless [errors[:profile_phones], errors[:profile_emails]].flatten.blank?
  end

  has_many :profile_achievements
  has_many :achievements, through: :profile_achievements
  has_many :transactions, foreign_key: :recipient_id

  has_many :resumes, dependent: :destroy, inverse_of: :profile, after_add: :check_achievements
  has_many :personal_notifications, dependent: :destroy
  accepts_nested_attributes_for :resumes, reject_if: :all_blank, allow_destroy: true

  #accepts_nested_attributes_for :user

#  belongs_to :manager, class_name: 'Profile', required: false
#  belongs_to :department, primary_key: :code, foreign_key: :department_code, required: false
#  belongs_to :position, primary_key: :code, foreign_key: :position_code

  has_many :legal_unit_employees, -> { where default: false }, dependent: :destroy
  has_one :default_legal_unit_employee, -> { where default: true }, class_name: 'LegalUnitEmployee', dependent: :destroy
  has_many :all_legal_unit_employees, class_name: 'LegalUnitEmployee', dependent: :destroy

  has_many :profile_mailing_lists, inverse_of: :profile, dependent: :destroy
  has_many :mailing_lists, through: :profile_mailing_lists

  has_many :uploaded_documents, class_name: 'Document', foreign_key: :uploaded_by_id, dependent: :destroy

  has_many :managed_projects, foreign_key: :manager_id, dependent: :destroy, class_name: 'Project'

  has_many :profile_projects, dependent: :destroy, after_add: :check_achievements
  has_many :projects, through: :profile_projects
  has_one :legal_unit, through: :default_legal_unit_employee

  has_many :favorite_posts
  has_many :favorite_discussions, dependent: :destroy
  has_many :discussions, through: :favorite_discussions
  has_many :posts, through: :favorite_posts

  has_many :profile_reading_entities, dependent: :destroy

  has_many :skills, -> { order 'skill_confirmations_count desc NULLS LAST, name asc' }, dependent: :destroy

  has_many :profile_phones, dependent: :destroy, inverse_of: :profile
  has_one :preferred_phone, -> { where(preferable: true) }, class_name: 'ProfilePhone', foreign_key: :profile_id, dependent: :destroy
  accepts_nested_attributes_for :profile_phones, reject_if: :all_blank, allow_destroy: true

  has_many :profile_emails, dependent: :destroy, inverse_of: :profile
  has_one :preferred_email, -> { where(preferable: true) }, class_name: 'ProfileEmail', foreign_key: :profile_id, dependent: :destroy
  accepts_nested_attributes_for :profile_emails, reject_if: :all_blank, allow_destroy: true

  has_many :profile_messengers, dependent: :destroy, inverse_of: :profile
  accepts_nested_attributes_for :profile_messengers, reject_if: :all_blank, allow_destroy: true

  accepts_nested_attributes_for :default_legal_unit_employee, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :skills, reject_if: :all_blank, allow_destroy: true

  enum sex: [:male, :female], _suffix: true
  enum marital_status: [:single, :married, :divorced, :widowed]
  validates_numericality_of :kids, greater_than_or_equal_to: 0

  scope :not_admins, -> { includes(user: :roles).where.not('users' => { 'roles' => { 'name' => 'admin' } }) } #TODO: WTF: Tell me why hashes is working here but not colons (new notation)???
  scope :default_order, -> { order(surname: :asc).order(name: :asc).order(middlename: :asc) }
  scope :not_blocked, -> { includes(:user).where(users: { status: 'active' }) }
  scope :blocked, -> { includes(:user).where(users: { status: 'blocked' }) }
  scope :by_lue, -> (ids) { includes(:all_legal_unit_employees).where(legal_unit_employees: { legal_unit_id: ids }).references(:legal_unit_employees) }

  mount_uploader :photo, PhotoUploader

  scope :search_import, -> {includes(:user).not_blocked}

  FI_FORMAT = { with: /\A([A-Za-zА-яЁё]+-)*([А-яA-Za-zЁё]+)\z/, message: "может содержать только буквы и дефис" }.freeze
  MIDDLENAME_FORMAT = { with: /((\A(([A-Za-zА-яЁё]+-)*([А-яA-Za-zЁё]+))\z)|(\A\z))/, message: "может содержать только буквы и дефис" }.freeze
  validates :name, :surname, presence: true, format: FI_FORMAT
  validates :middlename, format: MIDDLENAME_FORMAT
  validates :birthday, presence: true

  after_update :send_user_notification

  def phone
    res = preferred_phone&.number
    res = profile_phones&.first&.number unless res&.present?
    res = default_legal_unit_employee&.phone_work unless res&.present?
    res = default_legal_unit_employee&.phone_corporate unless res&.present?
    res if res&.present?
  end

  def email
    res = preferred_email&.email
    res = profile_emails&.first&.email unless res&.present?
    res = default_legal_unit_employee&.email_work unless res&.present?
    res = default_legal_unit_employee&.email_corporate unless res&.present?
    res = user&.email unless res&.present?
    res if res&.present?
  end

  def telegram
    profile_messengers&.find_by(name: 'Telegram')&.phones&.first || profile_phones&.find_by(telegram: true, preferable: true)&.number || profile_phones&.find_by(telegram: true)&.number&.first
  end

  def should_index?
    user&.active?
  end

  def age
    (Date.today - birthday).div(365.25) if birthday
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
    default_legal_unit_employee&.legal_unit_employee_position&.position&.name_ru
  end

  def managers_chain
    subordination_chain.map { |x| Profile.find(x).as_json({ methods: [:subordinates_count, :position_name] }) }.reverse
  end

  def subordinates_list
    subordinates.as_json({ methods: [:subordinates_count, :position_name] })
  end

  # def as_indexed_json(options = {})
  #   self.as_json(only: %i[name surname middlename city],
  #                include: {
  #                    all_legal_unit_employees: {
  #                        include: {
  #                            position: {
  #                                include: {position: {only: %i[name_ru position_code]}},
  #                                only: %i(position position_code)
  #                            },
  #                            state: {
  #                                only: :state
  #                            },
  #                            departments_chain: {
  #                                only: %i[id name_ru parent_id]
  #                            }
  #                        },
  #                        only: %i[position state legal_unit_id wage_rate wage default office_id contract_type_id contract_ends_at structure_unit]
  #                    },
  #                    skills: {
  #                        only: :name
  #                    },
  #                    resumes: {
  #                        include:
  #                            {
  #                                resume_work_experiences: {only: %i(position experience_description)},
  #                                resume_educations: {
  #                                    include: {education_level: {only: :name}},
  #                                    only: %i(school_name faculty_name speciality education_level)
  #                                },
  #                                language_skills: {
  #                                    language: {only: %i(name)},
  #                                    only: :language
  #                                },
  #                                resume_certificates: {
  #                                    only: %i(name company_name)
  #                                },
  #                                resume_courses: {
  #                                    only: %i(company_name name end_year)
  #                                }
  #                            },
  #                        only: %i[resume_work_experiences resume_educations language_skills resume_certificates resume_courses]
  #                    }
  #                }
  #   )
  # end

  private

  def set_updater
    if valid?
      self.updater = RequestStore.store[:current_user]&.profile
    end
  end

  def remove_blank_social_urls
    social_urls.reject!(&:blank?)
  end

# ПОИСК И ФИЛЬТРАЦИЯ:

  # settings index: { number_of_shards: 1 } do
  #   mappings do
  #     # indexes 'surname', index: 'not_analyzed', type: 'string'
  #     indexes 'resumes.resume_courses.end_year', index: 'not_analyzed', type: 'string'
  #     indexes 'skills.name', index: 'not_analyzed', type: 'string'
  #     indexes 'all_legal_unit_employees', type: 'nested', properties: {
  #         'departments_chain.name_ru' => {index: 'not_analyzed', type: 'string'},
  #         'state.state' => {index: 'not_analyzed', type: 'string'}
  #     }
  #   end
  # end

end
