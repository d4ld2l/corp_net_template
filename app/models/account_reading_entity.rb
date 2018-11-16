class AccountReadingEntity < ApplicationRecord
  belongs_to :account
  belongs_to :readable, polymorphic: true

  validates_uniqueness_of :readable_id, scope: %i[readable_type account_id]
end
