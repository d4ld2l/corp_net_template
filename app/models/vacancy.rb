class Vacancy < ApplicationRecord
  include DiscussableModel
  include TaskableModel
  include Elasticsearch::Model
  include Indexable
  include Vacancies::StateMachine

  enum type_of_salary: {
    gross: 1,
    net: 2
  }

  enum type_of_contract: {
    indefinite: 1,
    fixed_term: 2,
    gpc: 3
  }

  acts_as_tenant :company

  before_destroy { CandidateChange.where(vacancy_id: id).destroy_all }

  after_create :notify_creation
  before_save :notify_assignment, :notify_in_progress, :notify_update, :notify_cancellation, :notify_paused, :notify_new_accounts, :notify_status_changed

  has_many :vacancy_stages, -> { order(position: :asc) }, class_name: 'VacancyStage', dependent: :destroy
  belongs_to :current_stage, class_name: 'VacancyStage',
             foreign_key: 'current_stage_id'
  has_many :account_vacancies, dependent: :destroy
  has_many :accounts, through: :account_vacancies
  belongs_to :manager, class_name: 'Account', foreign_key: :manager_id
  belongs_to :owner, class_name: 'Account', foreign_key: :owner_id
  belongs_to :creator, class_name: 'Account', foreign_key: :creator_id

  has_many :candidate_vacancies, dependent: :destroy
  has_many :candidates, -> { uniq }, through: :candidate_vacancies

  has_many :documents, as: :document_attachable, class_name: 'Document', dependent: :destroy

  accepts_nested_attributes_for :vacancy_stages, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :manager, reject_if: :all_blank
  accepts_nested_attributes_for :account_vacancies, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :candidate_vacancies, reject_if: :all_blank, allow_destroy: false
  accepts_nested_attributes_for :documents, reject_if: :all_blank, allow_destroy: true


  scope :only_available, ->(account_id) { where("creator_id = #{account_id} or owner_id = #{account_id} or status = 'archived'") }
  scope :as_creator_or_owner, ->(account_id) { where("creator_id = #{account_id} or owner_id = #{account_id}") }
  scope :as_manager, ->(account_id) { where('manager_id = ?', account_id) }
  scope :as_creator, ->(account_id) { where('creator_id = ?', account_id) }
  scope :as_owner, ->(account_id) { where('owner_id = ?', account_id) }
  scope :default_order, -> { order(updated_at: :desc) }

  # with_options for manager and recruiter
  #mount_uploader :file, FileOfVacancyUploader
  mount_base64_uploader :file, FileOfVacancyUploader

  def count_ratings_by_stages_aux
    @ratings_aux ||= VacancyStage.where(vacancy_id: id)
                       .joins(candidate_vacancies: :candidate_ratings)
                       .where('candidate_ratings.vacancy_stage_id = candidate_vacancies.current_vacancy_stage_id')
                       .where('candidate_ratings.updated_at = (SELECT created_at FROM candidate_ratings cr WHERE candidate_ratings.vacancy_stage_id = cr.vacancy_stage_id AND candidate_ratings.candidate_vacancy_id = cr.candidate_vacancy_id AND cr.value IS NOT NULL ORDER BY updated_at DESC LIMIT 1) AND candidate_ratings.value IS NOT NULL')
                       .group(['vacancy_stages.id', 'candidate_ratings.value'])
                       .count
  end

  def count_ratings_by_stages
    aux = count_ratings_by_stages_aux
    @ratings = {}
    aux.each do |(k1, k2), v|
      @ratings[k1] ||= {}
      @ratings[k1][k2] = v
    end
    @ratings
  end

  def count_candidates_by_stages
    @candidates_counter ||= VacancyStage.where(vacancy_id: id)
                              .joins(:candidate_vacancies)
                              .where(evaluation_of_candidate: true)
                              .group('vacancy_stages.id').count
  end

  def count_unrated_by_stages
    candidates_count_by_stages = count_candidates_by_stages
    candidates_count_by_stages.each do |k, v|
      candidates_count_by_stages[k] = v - count_ratings_by_stages_aux.select { |kr, _| kr.include? k }.inject(0) { |c, (_, vr)| c + vr }
    end
  end

  def status_name
    I18n.t("activerecord.enum.vacancy_status.#{self.status}")
  end

  private

  def notify_creation
    account = Role.find_by_name('recruitment_general_recruiter').accounts
    AutoNotificationsMailer.vacancy_created(to_mailer, [creator&.email, account.map(&:email)].flatten.compact).deliver_later
    uids = creator_id == manager_id ? [] : [ manager&.uid ]
    DchVacancyNotificationsWorker.perform_async(to_mailer, uids.flatten.compact, :new_vacancy_assignment)
  end

  def notify_paused
    if valid? && status_changed? && status == 'paused'
      current_account = RequestStore.store[:current_account]
      AutoNotificationsMailer.vacancy_paused(to_mailer, ([creator&.email, owner&.email] - [current_account&.email]).compact, current_account&.full_name).deliver_later
      # UNI-7146
      # DchVacancyNotificationsWorker.perform_async(to_mailer, ([creator&.uid, owner&.uid] - [current_account&.uid]).compact, :vacancy_paused, current_account&.full_name)
    end
  end

  def to_mailer
    { name: name, block: block, practice: practice, id: id, manager: creator&.full_name, recruiter: owner&.full_name, status: status_name, status_was: status_was, current_account_full_name: RequestStore.store[:current_account]&.full_name }.to_json
  end

  def notify_assignment
    if valid? && owner_id_changed?
      AutoNotificationsMailer.vacancy_assigned(to_mailer, owner&.email).deliver_later
      DchVacancyNotificationsWorker.perform_async(to_mailer, [owner&.uid], :vacancy_assignment)
    end
  end

  def notify_in_progress
    if valid? && status_changed? && status == 'worked' && %w(new paused).include?(status_was)
      accounts = Role.find_by_name('recruitment_general_recruiter').accounts
      AutoNotificationsMailer.vacancy_in_progress(to_mailer, [creator&.email, accounts.map(&:email)].flatten.compact).deliver_later
      # UNI-7146
      # DchVacancyNotificationsWorker.perform_async(to_mailer, [creator&.uid, accounts.map(&:uid)].flatten.compact, :vacancy_in_progress)
    end
  end

  def notify_update
    if valid? && persisted? && !owner_id_changed? && !status_changed?
      AutoNotificationsMailer.vacancy_update(to_mailer, owner&.email, 'отредактирована').deliver_later
      # UNI-7146
      # DchVacancyNotificationsWorker.perform_async(to_mailer, [owner&.uid], :vacancy_updated)
    end
  end

  def notify_cancellation
    if valid? && status_changed? && status == 'archived' && %w(new paused worked).include?(status_was)
      AutoNotificationsMailer.vacancy_update(to_mailer, owner&.email, 'отменена').deliver_later
      # UNI-7146
      # DchVacancyNotificationsWorker.perform_async(to_mailer, [owner&.uid], :vacancy_cancelled)
    end
  end

  def notify_status_changed
    if valid? && status_changed?
      uids = [creator&.uid, owner&.uid] - [RequestStore.store[:current_account]&.uid]
      DchVacancyNotificationsWorker.perform_async(to_mailer, uids, :status_changed)
    end
  end

  def notify_new_accounts
    accs = account_vacancies.to_a.select{ |x| !x.persisted? }
    if valid? && !accs.empty?
      DchVacancyNotificationsWorker.perform_async(to_mailer, accs.map{ |x| x.account&.uid }, :new_accounts_added)
    end
  end
end
