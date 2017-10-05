class EventParticipant < ApplicationRecord
  belongs_to :event
  belongs_to :participant, class_name: User, foreign_key: :user_id
end
