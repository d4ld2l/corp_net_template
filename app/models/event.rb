class Event < ApplicationRecord
  include DiscussableModel
  include TaskableModel
  belongs_to :created_by, class_name: 'Account'
  belongs_to :event_type
  has_many :event_participants, dependent: :destroy
  has_many :participants, through: :event_participants, source: :participant, class_name: 'Account'
  has_many :documents, as: :document_attachable, dependent: :destroy # class_name: 'Base64Document', as: :base64_doc_attachable,

  accepts_nested_attributes_for :event_participants, allow_destroy: true
  accepts_nested_attributes_for :documents, allow_destroy: true

  scope :available_for_account_as_participant, ->(x) { includes(:event_participants).where(event_participants: { account_id: x }) }
  scope :available_for_account_as_creator, ->(x) { includes(:event_participants).references(:event_participants).where(created_by_id: x) }
  scope :available_for_account, ->(x) { available_for_account_as_creator(x).or(available_for_account_as_participant(x)) }
  scope :default_order, -> { order(created_at: :desc) }

  validates :name, length: { maximum: 200 }, presence: true
  validates :starts_at, :ends_at, :created_by_id, presence: true
  validate :start_less_then_end
  validates :place, length: { maximum: 255 }, if: -> { place.present? }

  before_update :notify_participants_update
  before_create :notify_participants_update, if: -> { available_for_all? }
  before_update :notify_participants_when_set_public
  before_destroy :notify_participants_delete, prepend: true
  #before_save :update_participants_count

  def self.available_accounts_count
    @@available_accounts_count ||= Account.not_blocked.count
  end

  def participants_count
    available_for_all? ? Event.available_accounts_count : super
  end

  def event_participants_list
    available_for_all? ? Account.not_blocked.map { |acc| EventParticipant.new(participant: acc, event: self) } : event_participants
  end

  def update_participants_count!
    update_participants_count
    save!
  end

  private

  def update_participants_count
    self.participants_count = event_participants.count
  end

  def start_less_then_end
    if starts_at && ends_at && starts_at > ends_at
      errors.add(:ends_at, 'Должна быть больше даты начала')
      errors.add(:starts_at, 'Должна быть меньше даты окончания')
    end
  end

  def notify_participants(type)
    EventNotifierWorker.perform_async(participants: event_participants_list.map { |x| x.email&.present? ? x.email : x.participant&.email },
                                      event: as_json(methods: [:changes], include: { event_type: {}, created_by: { methods: [:full_name] } }), type: type)
  end

  def notify_participants_delete
    notify_participants('destroy')
  end

  def notify_participants_update
    notify_participants(new_record? ? 'create' : 'update') if changes.keys.any? { |x| %w[name event_type_id description place starts_at ends_at].include?(x) }
  end

  def notify_participants_when_set_public
    notify_participants('create') if changes.key?('available_for_all') && changes['available_for_all'][1] == true
  end
end
