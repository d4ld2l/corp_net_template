# Заявки
class Bid < ApplicationRecord
  include DiscussableModel
  include TaskableModel
  belongs_to :service
  belongs_to :author, class_name: 'Account', foreign_key: :author_id
  belongs_to :manager, class_name: 'Account', foreign_key: :manager_id, optional: true
  belongs_to :matching_user, class_name: 'Account', foreign_key: :matching_user_id, optional: true
  belongs_to :assistant, class_name: 'Account', foreign_key: :assistant_id
  belongs_to :creator, class_name: 'Account', foreign_key: :creator_id, optional: true
  has_many :comments, -> { order(:created_at) }, as: :commentable, class_name: 'Comment', dependent: :destroy, validate: false
  has_one :bids_bid_stage
  has_one :bid_stage, through: :bids_bid_stage
  alias_attribute :status, :bid_stage
  belongs_to :legal_unit
  include Elasticsearch::Model
  include Indexable

  # optional associations

  ## Representation Allowance
  has_one :representation_allowance, dependent: :destroy
  has_one :information_about_participant, through: :representation_allowance
  has_one :meeting_information, through: :representation_allowance
  has_many :participants, through: :information_about_participant
  accepts_nested_attributes_for :representation_allowance

  ## BYOD
  has_one :byod_information, dependent: :destroy
  accepts_nested_attributes_for :byod_information

  # Team building
  has_one :team_building_information, dependent: :destroy
  accepts_nested_attributes_for :team_building_information

  # bonus
  has_one :bonus_information, dependent: :destroy
  accepts_nested_attributes_for :bonus_information

  accepts_nested_attributes_for :comments, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :bids_bid_stage

  before_validation :set_matching_user, if: -> { matching_user.blank? }
  before_validation :set_initial_stage, if: -> { bid_stage.blank? && service_id&.present? }
  before_save :manager_mapping

  validate :only_one_type, on: :create
  validates :legal_unit_id, :service_id, presence: true

  after_create :send_zero_transition_notifications

  acts_as_tenant :company

  def all_stages
    service.bid_stages_group.bid_stages.pluck(:code, :name).to_h
  end

  def allowed_stage?(code)
    allowed_statuses = self.bid_stage.get_allowed_stages.uniq
    allowed_statuses.include?(code)
  end

  def allowed_stages
    self.bid_stage.get_allowed_stages_for_api.uniq
  end

  def apply_state(code)
    if allowed_stage? code
      apply_allowed_stage code
    else
      errors.add(:not_allowed_state, 'Not allowed state')
      false
    end
  end

  def manager_mapping
    if new_record?
      # self.manager = author
    else
      allowed = service.bid_stages_group.allowed_bid_stages
                  .where(allowed_stage_id: bids_bid_stage.bid_stage_id_was,
                         current_stage_id: bids_bid_stage.previous_changes['bid_stage_id']&.at(0)).first

      if allowed&.present?
        self.manager = if allowed&.executor == 'author'
                         author
                       elsif allowed&.executor == 'assistant'
                         assistant
                       elsif allowed&.executor == 'matching_user'
                         matching_user
                       else
                         allowed&.additional_executor&.account
                       end
      end
    end
  end

  def build_content_for_docx
    if self.team_building_information.present?
      Reports::TeamBuildingBidBuilder.new(resource: self).build_report
    else
      Reports::BidBuilder.new(resource: self).build_report
    end

  end

  def as_indexed_json(options = {})
    self.as_json(
      only: %i[author_id service_id manager_id created_at],
      include: {
        bids_bid_stage: { only: :bid_stage_id }
      }
    )
  end

  def self.search(query, params = {})
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
             { created_at: { order: :desc } }]
    }
    __elasticsearch__.search(es_query)
  end

  private

  def self.filter_array(query, params = {})
    search_params_array = []
    search_params_array += date_params(params)
    search_params_array +=
      params.map do |k, v|
        unless v.blank?
          case
          when k == 'service_id'
            {
              bool: {
                should: v.map { |x| { match: { 'service_id' => x } } }
              }
            }
          when k == 'stage_id'
            {
              bool: {
                should: v.map { |x| { match: { 'bids_bid_stage.bid_stage_id' => x } } }
              }
            }
          when k == 'author_id'
            {
              bool: {
                should: v.map { |x| { match: { 'author_id' => x } } }
              }
            }
          when k == 'manager_id'
            {
              bool: {
                should: v.map { |x| { match: { 'manager_id' => x } } }
              }
            }
          end
        end
      end
    search_params_array.compact
  end

  def self.date_params(params)
    date_params = []
    unless params.slice("created_at_from", "created_at_to").values.all?(&:blank?)
      date_params <<
        {
          range: {
            created_at: {
              gte: params["created_at_from"]&.to_date,
              lte: params["created_at_to"]&.to_date
            }.delete_if { |_, v| v.blank? }
          }
        }
    end
    date_params
  end

  private

  def send_zero_transition_notifications
    if self.service.bid_stages_group.initial_notification?
      emails = []
      self.service.bid_stages_group.initial_notifiable.each do |x|
        case x
        when "author"
          emails << self.author.email
        when "matching_user"
          emails << self.matching_user&.email
        when "assistant"
          emails << self.assistant&.email
        end
      end
      BidMailer.notification_about_change_state(self, emails).deliver_later if emails.present?
    end
  end

  def set_initial_stage
    # Setting the manager (executor)
    if self.manager.nil?
      if self.service.bid_stages_group.initial_executor != nil
        executor = service.bid_stages_group.initial_executor
        self.manager_id = if executor == 'author'
                            self.author_id
                          elsif executor == 'assistant'
                            self.assistant_id
                          elsif executor == 'matching_user'
                            self.matching_user_id
                          else
                            self.author_id
                          end
      else
        self.manager_id = self.author_id
      end
    end
    self.bid_stage = service.bid_stages_group.bid_stages.find_by_initial(true) #.find_by_code(:draft)
  end

  def need_change_manager_to_author?
    self && bid_stage&.code&.in?(%w[draft rejected revision_required])
  end

  def apply_allowed_stage(code)
    PersonalNotification.where(issuer_id: id, issuer_type: self.class.name, account_id: manager&.id).update_all(issuer_id: nil, issuer_type: nil)
    next_stage = service.bid_stages_group.bid_stages.find_by_code(code)
    allowed_stage = bid_stage.allowed_bid_stages&.where(allowed_stage_id: next_stage.id, current_stage_id: bid_stage.id)&.first
    notification = allowed_stage&.notification?
    emails = allowed_stage&.bids_executors&.map { |r| r&.account&.email }
    emails += get_notifiables_emails(allowed_stage&.notifiable || [])
    self.bid_stage = next_stage
    save validate: false
    BidMailer.notification_about_change_state(self, emails).deliver_later if notification
    PersonalNotificationsWorker.perform_async(account_id: manager_id, action_type: :bid_status_changed, issuer_json: to_issuer_json, initiator_id: RequestStore[:current_account]&.id) if notification
    true
  end

  def get_notifiables_emails(notifiables)
    res = notifiables&.reject { |x| x.empty? }
    res.map { |x| send(x)&.email }
  end

  def set_matching_user
    self.matching_user = service&.contacts&.first
  end

  def only_one_type
    if [:representation_allowance, :byod_information, :team_building_information].map { |x| self.send(x)&.present? }.count { |x| x } != 1
      errors.add(:bid_type, "Может быть только один тип заявки")
    end
  end
end
