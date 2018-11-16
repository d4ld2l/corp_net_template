class Resume < ApplicationRecord
  belongs_to :account, required: false, inverse_of: :resumes
  belongs_to :candidate, required: false, inverse_of: :resume
  belongs_to :resume_source, required: false
  belongs_to :raw_resume_doc, class_name: 'Document', foreign_key: :raw_resume_doc_id, dependent: :destroy
  has_many :professional_specializations_resumes, dependent: :destroy
  has_many :professional_specializations, through: :professional_specializations_resumes
  has_many :resume_documents, as: :document_attachable, class_name: 'Document', dependent: :destroy
  has_many :resume_certificates, dependent: :destroy
  has_many :resume_skills, dependent: :destroy # TODO: confirmations
  has_many :additional_contacts, dependent: :destroy
  has_many :language_skills, dependent: :destroy
  has_many :resume_work_experiences, dependent: :destroy
  has_many :resume_recommendations, dependent: :destroy
  has_many :resume_educations, dependent: :destroy
  has_many :resume_qualifications, dependent: :destroy
  has_many :resume_courses, dependent: :destroy
  has_many :resume_contacts, dependent: :destroy
  has_one :preferred_contact, -> { where(preferred: true) }, class_name: 'ResumeContact', dependent: :destroy
  belongs_to :education_level, optional: true

  has_one :last_work_experience, -> { order('CASE WHEN end_date IS NULL THEN 1 ELSE 0 END DESC, end_date DESC, start_date ASC') }, class_name: 'ResumeWorkExperience', dependent: :destroy

  accepts_nested_attributes_for :resume_work_experiences, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :additional_contacts, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :language_skills, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :resume_recommendations, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :resume_certificates, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :resume_courses, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :resume_qualifications, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :resume_educations, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :professional_specializations, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :professional_specializations_resumes, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :resume_documents, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :resume_contacts, reject_if: :all_blank, allow_destroy: true

  validates_length_of :professional_specializations, maximum: 3
  validate :validate_preferred_contacts

  enum sex: %i[male female undefined], _suffix: true
  enum martial_condition: %i[never_married married divorced], _suffix: true
  enum have_children: %i[true false undefined], _suffix: true

  scope :only_my, ->(account_id) { where(account_id: account_id) }

  acts_as_taggable_on :skills

  before_save { candidate&.touch if candidate && valid? && persisted? }
  before_save :update_summary_work_period
  after_touch { candidate&.touch if candidate }

  # mount_uploader :photo, ResumePhotoUploader
  mount_base64_uploader :photo, ResumePhotoUploader
  mount_uploaders :documents, ResumeDocumentsUploader
  mount_uploader :resume_file, ResumeFileUploader
  mount_base64_uploader :resume_file, ResumeFileUploader

  def last_position
    last_work_experience&.position
  end

  def language_list
    language_skills.joins(:language).distinct.pluck('languages.name').map{|x| {name: x}}
  end

  def full_name
    [candidate&.last_name, candidate&.first_name, candidate&.middle_name].compact.join(' ')
  end

  def summary_work_period
    if (work_period_request_expiration_date - Date.current).to_i <= 0
      if persisted?
        save(validate: false)
      else
        update_summary_work_period
      end
    end
    last_requested_work_period
  end

  def update_summary_work_period
    if respond_to?(:work_period_request_expiration_date)
      first_workdate = Date.today + 1.day
      experience = resume_work_experiences # .sort{|a,b| a.start_date <=> b.start_date}
      experience.each.map { |x| first_workdate = x.start_date if first_workdate > x.start_date }

      months_until_now = get_months_between_dates(Date.today, first_workdate)

      array_of_months = Array.new(months_until_now, false)

      experience.each do |exp|
        start_date = exp.start_date
        end_date = exp.end_date
        end_date = Date.today if end_date.nil?
        total_months_in_curr_exp = get_months_between_dates(start_date, end_date)
        num_of_starting_month = get_months_between_dates(first_workdate, start_date)
        for i in 0..total_months_in_curr_exp do
          array_of_months[num_of_starting_month + i] = true
        end
      end
      self.work_period_request_expiration_date = Date.today + 1.month
      self.last_requested_work_period = array_of_months.count(true)
    else
      0
    end
  end

  def get_months_between_dates(date1, date2)
    date1, date2 = date2, date1 if date2 > date1
    months = (date1.year * 12 + date1.month) - (date2.year * 12 + date2.month)
    # months += 1 if date1.day > date2.day
    months
  end

  def get_end_date(work_period)
    work_period.end_date = Date.today unless work_period.end_date&.present?
    work_period
  end

  def periods_intersection(wp, wp_next)
    wp.end_date = Date.today unless wp.end_date.present?
    if wp_next && wp_next.start_date < wp.end_date
      end_next_period = [wp.end_date, wp_next.end_date || Date.today].min
      return (end_next_period.month + 1 + end_next_period.year * 12) - (wp_next.start_date.month + wp_next.start_date.year * 12)
    else
      0
    end
  end

  def period_duration(start_date, end_date)
    (end_date.month + end_date.year * 12) - (start_date.month + start_date.year * 12)
  end

  def validate_preferred_contacts
    errors.add('resume_contacts.preferred', 'Должен быть один предпочитаемый способ связи') unless resume_contacts.map { |x| x.preferred? && !x.marked_for_destruction? }.count { |x| x } <= 1
  end
end
