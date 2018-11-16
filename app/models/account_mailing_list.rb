class AccountMailingList < ApplicationRecord
  belongs_to :account, inverse_of: :account_mailing_lists, touch: true
  belongs_to :mailing_list, inverse_of: :account_mailing_lists, touch: true

  validates_uniqueness_of :account_id, scope: :mailing_list_id
end
