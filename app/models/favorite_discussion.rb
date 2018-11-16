class FavoriteDiscussion < ApplicationRecord
  belongs_to :account
  belongs_to :discussion

  validates_uniqueness_of :discussion_id, scope: :account_id
end
