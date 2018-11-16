class MailingList < ApplicationRecord
  include DiscussableModel
  include TaskableModel
  include Elasticsearch::Model
  include Indexable
  belongs_to :creator, class_name: 'Account', foreign_key: :account_id
  validates :name, presence: true, length: { maximum: 255 }
  has_many :account_mailing_lists, inverse_of: :mailing_list, dependent: :destroy
  has_many :accounts, -> { not_blocked }, through: :account_mailing_lists
  belongs_to :importable, polymorphic: true, optional: true
  accepts_nested_attributes_for :account_mailing_lists, allow_destroy: true, reject_if: :all_blank

  scope :available_for_account_as_participant, ->(x) { where("id IN (SELECT mailing_list_id FROM account_mailing_lists WHERE account_mailing_lists.account_id = #{x})") }
  scope :available_for_account_as_creator, ->(x) { where(account_id: x) }
  scope :available_for_account, ->(x) { available_for_account_as_creator(x).or(available_for_account_as_participant(x)) }

  after_create ->(x) { x.send_notification('create') }
  after_update ->(x) { x.send_notification('update') }
  after_touch ->(x) { x.send_notification('update') }
  before_destroy ->(x) { x.send_notification('delete') }

  before_create { self.creator = RequestStore.store[:current_account] }

  acts_as_tenant :company

  def accounts_count
    accounts.count
  end

  def as_indexed_json(_options = {})
    as_json(only: %i[name id])
  end

  def send_notification(type)
    kafka_connector = Kafka::Connector.new('mailing_lists')
    kafka_connector.send([JSON.dump(to_notification_hash)], type)
  rescue StandardError
    nil
  end

  def to_notification_hash
    {
      id: id,
      name: name,
      creator_id: user_id,
      user_ids: accounts.ids
    }
  end
end
