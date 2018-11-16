class Like < ApplicationRecord
  belongs_to :likable, polymorphic: true, counter_cache: true
  belongs_to :account

  after_create_commit :notify_users
  before_destroy :delete_notifications

  private

  def delete_notifications
    PersonalNotification.where(issuer_id: id, issuer_type: self.class.name).destroy_all
  end

  def notify_users
    case likable_type
    when 'Post'
      PersonalNotificationsWorker.perform_async(account_id: likable&.author_id, action_type: :post_liked, issuer_json: to_issuer_json, initiator_id: RequestStore[:current_account]&.id)
    when 'Comment'
      case likable.commentable_type
      when 'NewsItem'
        PersonalNotificationsWorker.perform_async(account_id: likable&.account_id, action_type: :news_item_comment_liked, issuer_json: to_issuer_json, initiator_id: RequestStore[:current_account]&.id)
      when 'Post'
        PersonalNotificationsWorker.perform_async(account_id: likable&.account_id, action_type: :post_comment_liked, issuer_json: to_issuer_json, initiator_id: RequestStore[:current_account]&.id)
      end
    end
  end
end
