module LikableModel
  extend ActiveSupport::Concern

  included do
    has_many :likes, as: :likable, dependent: :destroy

    def already_liked?(liker_account_id)
      likes.to_a.keep_if { |x| x.account_id == liker_account_id }.any?
    end
  end
end
