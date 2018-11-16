class EventParticipant < ApplicationRecord
  belongs_to :event, touch: true
  belongs_to :participant, class_name: 'Account', foreign_key: :account_id

  after_create :notify_new_participant
  after_save :update_event_counter

  def notify_new_participant
    self.email = email&.present? ? email : participant&.email
    EventNotifierWorker.perform_async(participants: [email],
                                      event: event.as_json(methods: [:changes], include: { event_type: {}, created_by: { methods: [:full_name] } }),
                                      type: 'create')
  end

  private

  def update_event_counter
    event&.update_participants_count!
  end
end
