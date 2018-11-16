class Mention < ApplicationRecord
  belongs_to :account
  belongs_to :post, optional: true # TODO: remove, deprecated
  belongs_to :mentionable, polymorphic: true

  after_create_commit :notify_users
  before_destroy :change_notification

  private

  def change_notification
    PersonalNotification.where(issuer_id: id, issuer_type: self.class.name).destroy_all
  end

  def notify_users
    PersonalNotificationsWorker.perform_async(account_id: account_id, action_type: :user_mentioned, issuer_json: to_issuer_json, initiator_id: RequestStore[:current_account].id) if mentionable_type == 'Post'
  end
end
