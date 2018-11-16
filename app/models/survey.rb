class Survey < ApplicationRecord
  include AASM
  include ChangeAasmState
  include Elasticsearch::Model
  include Indexable
  include DiscussableModel
  include TaskableModel

  enum survey_type: {
    simple: 1,
    complex: 2
  }

  has_many :questions, -> { order(position: :asc) }, dependent: :destroy
  has_many :survey_results, dependent: :destroy
  belongs_to :creator, class_name: 'Account', optional: true
  belongs_to :editor, class_name: 'Account', optional: true
  belongs_to :publisher, class_name: 'Account', optional: true
  belongs_to :unpublisher, class_name: 'Account', optional: true

  has_many :survey_participants, dependent: :destroy
  has_many :participants, through: :survey_participants, source: :account
  has_many :documents, as: :document_attachable, class_name: 'Document'

  scope :available_for_account_as_participant, ->(x) { where("id IN (SELECT survey_id FROM survey_participants WHERE account_id = #{x})") }
  scope :available_for_account_as_creator, ->(x) { where(creator_id: x) }
  scope :available_for_all, -> { where available_to_all: true }
  scope :available_for_account, ->(x) { available_for_account_as_participant(x).or(available_for_all).or(available_for_account_as_creator(x)) }
  scope :new_surveys, ->(x) { only_published.available_for_account(x).where("id NOT IN (SELECT survey_id FROM survey_results WHERE account_id = #{x})") }
  scope :passed_surveys, ->(x) { available_for_account(x).where("id IN (SELECT survey_id FROM survey_results WHERE account_id = #{x})") }
  scope :sort_by_participants, ->(asc: 'ASC') { order("(SELECT COUNT(DISTINCT account_id) AS count FROM survey_results WHERE survey_results.survey_id = \"surveys\".id GROUP BY survey_id) #{asc}") }
  scope :only_published, ->{ where(state: 'published') }

  accepts_nested_attributes_for :questions, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :survey_participants, allow_destroy: true
  accepts_nested_attributes_for :documents, reject_if: :all_blank, allow_destroy: true

  acts_as_tenant :company

  mount_uploader :symbol, ImageSurveyUploader
  mount_base64_uploader :symbol, ImageSurveyUploader
  mount_base64_uploader :document, DocumentUploader
  mount_base64_uploader :document, DocumentUploader

  aasm column: :state do
    state :draft, initial: true
    state :published, :unpublished, :archived

    event :to_published do
      transitions from: %i[draft unpublished], to: :published
    end

    event :to_unpublished do
      transitions from: :published, to: :unpublished
    end

    event :to_archived do
      transitions from: %i[draft unpublished], to: :archived
    end
  end

  validates :name, :survey_type, presence: true
  validate :ends_at_must_great_than_current
  validates :questions, length: { in: 1..50, message: 'Количество вопросов для опроса или голосования может быть от 1 до 50' }
  with_options unless: -> { available_to_all? } do |s|
    s.validates :survey_participants, length: { minimum: 1, message: 'Должен существовать хотя бы один участник' }
  end

  before_save do
    remove_scheduled if valid? && state_changed? && unpublished? && persisted?
    notify_participants if valid? && state_changed? && published? && persisted?
    schedule_notification if valid? && state_changed? && published? && persisted?
    change_notifications_on_unpublish if valid? && state_changed? && unpublished? && persisted?
  end
  after_save :destroy_participants_if_available
  after_save do
    remove_unpublish_schedule
    SurveyUnpublishWorker.perform_at(self.ends_at, self.id) if self.ends_at
  end
  before_save :update_counters
  after_touch :update_counters!
  before_destroy :change_notifications_on_destroy, :remove_scheduled

  def complex_results
    if complex?
      collection = survey_results
      grouped = {}
      collection.flat_map(&:survey_answers).map(&:answers).map do |hash|
        hash.each do |key, value|
          key = OfferedVariant.find(key.to_i).wording
          grouped[key] ? grouped[key].push(value) : grouped[key] = [value]
        end
      end
      grouped.each { |key, value| grouped[key] = ((value.reject { |e| e == false }.size.to_f / collection.size) * 100).round(2) }
    end
  end

  def update(attributes, current_account = nil)
    with_transaction_returning_status do
      assign_attributes(attributes)
      if state_changed?
        if state == 'published'
          self.publisher = current_account
          self.published_at = DateTime.now
        elsif state == 'unpublished'
          self.unpublisher = current_account
          self.unpublished_at = DateTime.now
        end
      end
      save
    end
  end


  ## Counters & user-specific methods

  def update_counters
    self.participants_passed_count = survey_results.pluck(:account_id).uniq.count
    self.participants_total_count = available_to_all? ? Account.count : survey_participants.size
    self.questions_count = questions.size
  end

  def update_counters!
    update_counters
    save(validate: false)
  end

  def created_by_me
    creator_id == RequestStore.store[:current_account].id if RequestStore.store[:current_account]
  end

  def passed
    survey_results.select { |x| x.account_id == RequestStore.store[:current_account].id }.any? if RequestStore.store[:current_account]
  end


  ## Search

  def as_indexed_json(options = {})
    as_json(only: %i[id survey_type name note state anonymous creator_id publisher_id created_at updated_at published_at])
  end

  def self.search(query, params={})
    reserved_symbols = %w(+ - = && || > < ! ( ) { } [ ] ^ " ~ * ? : \\ /)
    search_query = query || ''
    # escaping reserved symbols
    reserved_symbols.each do |s|
      search_query.gsub!(s, "\\#{s}")
    end
    es_query = {
        query: {
        bool: {
            must: filter_array(search_query, params)
            },
        },
        sort: [{ _score: { order: :desc } },
               { published_at: { order: :desc } }]
    }
    __elasticsearch__.search( es_query )
  end

  private

  def self.filter_array(query, params={})
    search_params_array = []
    search_params_array += date_params(params)
    search_params_array +=
    params.map do |k, v|
      unless v.blank?
        case
          when k == 'q' && query.present?
            {
              bool: {
                  should: {
                      multi_match: {
                          query: query,
                          type: 'phrase_prefix',
                          fields: %w[name note]
                      }
                  },
              }
            }
          when k == 'anonymous' && v == '1'
            {
                bool: {
                    should: {
                        match: {
                            "anonymous": true
                        }
                    }
                }
            }
          when k == 'state'
            {
                bool: {
                    should: v.map {|x| {match_phrase: { 'state' => x}.delete_if {|_, v| v.blank?}}}
                }
            }
          when k == 'creator_id'
            {
                bool: {
                    should: v.map {|x| {match: { 'creator_id' => x}.delete_if {|_, v| v.blank?}}}
                }
            }
          when k == 'publisher_id'
            {
                bool: {
                    should: v.map {|x| {match: { 'publisher_id' => x}.delete_if {|_, v| v.blank?}}}
                }
            }
          when k == 'survey_type'
            {
                bool: {
                    should: {match: { 'survey_type' => v}}
                }
            }
        end
      end
    end
    search_params_array.compact
  end

  def self.date_params(params)
    date_params = []
    unless params.slice(:updated_at_from, :updated_at_to).values.all?(&:blank?)
      date_params <<
      {
          range: {
              updated_at: {
                  gte: params[:updated_at_from].to_date,
                  lte: params[:updated_at_to].to_date
              }.delete_if {|_, v| v.blank?}
          }
      }
    end
    unless params.slice(:published_at_from, :published_at_to).values.all?(&:blank?)
      date_params <<
          {
              range: {
                  published_at: {
                      gte: params[:published_at_from].to_date,
                      lte: params[:published_at_to].to_date
                  }.delete_if {|_, v| v.blank?}
              }
          }
    end
    unless params[:ends_at].blank?
      date_params <<
          {
              range: {
                  ends_at: {
                      gte: params[:ends_at].to_date,
                  }.compact
              }
          }
    end
    date_params
  end

  def destroy_participants_if_available
    survey_participants.destroy_all if available_to_all? && !survey_participants.empty?
  end

  def ends_at_must_great_than_current
    errors.add(:ends_at, 'Должно быть больше текущей даты') if ends_at && ends_at < Date.current
  end

  # Notifications & async

  def notify_participants
    SurveyPublishedNotifierWorker.perform_async(id)
  end

  def schedule_notification
    SurveyGoingToUnpublishedNotifierWorker.perform_at(ends_at - 1.day, id) if ends_at.present? && published_at < ends_at - 1.day
  end

  def change_notifications_on_unpublish
    PersonalNotification.where(issuer_id: id, issuer_type: self.class.name).where.not(account_id: creator&.id).update_all(issuer_id: nil, issuer_type: nil)
  end

  def change_notifications_on_destroy
    PersonalNotification.where(issuer_id: id, issuer_type: self.class.name).update_all(issuer_id: nil, issuer_type: nil)
  end

  def remove_scheduled
    sch = Sidekiq::ScheduledSet.new.select
    sch.each do |job|
      job.delete if job.klass == 'SurveyGoingToUnpublishedNotifierWorker' && job.args[0] == id
    end
  end

  def remove_unpublish_schedule
    sch = Sidekiq::ScheduledSet.new.select
    sch.each do |job|
      job.delete if job.klass == 'SurveyUnpublishWorker' && job.args[0] == id
    end
  end
end
