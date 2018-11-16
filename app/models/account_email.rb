class AccountEmail < ApplicationRecord
  belongs_to :account, inverse_of: :account_emails, touch: true
  enum kind: %i[personal work other]
end
