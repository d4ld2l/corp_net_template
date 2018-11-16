class Message < ApplicationRecord
  belongs_to :topic
  belongs_to :account
  has_many :children_messages, class_name: 'Message',
                              foreign_key: 'parent_message_id'
  belongs_to :parent_message, class_name: 'Message'

  validates :body, presence: true
end
