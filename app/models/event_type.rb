class EventType < ApplicationRecord
  has_many :events, dependent: :destroy

  acts_as_tenant :company
end
