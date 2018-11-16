class ProfileMailingList < ApplicationRecord
  belongs_to :profile, inverse_of: :profile_mailing_lists
  belongs_to :mailing_list, inverse_of: :profile_mailing_lists, touch: true

  validates_uniqueness_of :profile_id, scope: :mailing_list_id
end
