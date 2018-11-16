class Notification < ApplicationRecord
  belongs_to :notice, polymorphic: true
  belongs_to :account, optional: true
end
