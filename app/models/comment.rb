class Comment < ApplicationRecord
  include LikableModel
  include MentionableModel

  belongs_to :user, optional: true # TODO: delete it
  belongs_to :account
  belongs_to :commentable, polymorphic: true, counter_cache: true
  belongs_to :parent_comment, class_name: 'Comment', foreign_key: :parent_comment_id
  belongs_to :deleted_by, class_name: 'Account'
  has_many :children, class_name: 'Comment', foreign_key: :parent_comment_id

  has_many :documents, as: :document_attachable, dependent: :destroy
  has_many :photos, as: :photo_attachable, dependent: :destroy

  scope :only_top_level, -> { where(parent_comment_id: nil) }
  scope :not_nop_level, -> { where.not(parent_comment_id: nil) }

  # validates_presence_of :body, if: -> { self.documents.empty? } # UNI-5845
  validate :parent_must_have_same_commentable
  accepts_nested_attributes_for :documents, allow_destroy: true
  accepts_nested_attributes_for :photos, allow_destroy: true

  after_create_commit :notify_users
  before_destroy { PersonalNotification.where(issuer_id: id, issuer_type: self.class.name).destroy_all if commentable_type == 'Bid' }
  before_destroy { CandidateChange.where(change_for: self).destroy_all }

  after_destroy :update_discussion_last_at
  after_create :update_discussion_last_at
  after_create :update_candidate_history

  after_create_commit { ws_comment('discussion_comment_created') if commentable_type == 'Discussion' }
  after_update_commit { ws_comment('discussion_comment_edited') if commentable_type == 'Discussion' && !deleted_by.present? }

  def child_comments
    Comment.where(parent_comment_id: id)
  end

  def safe_delete(deleted_by_id = nil)
    assign_attributes({ deleted_at: DateTime.now, body: '<i>Сообщение было удалено</i>', deleted_by_id: deleted_by_id })
    self.documents.destroy_all
    self.photos.destroy_all
    self.save
    ws_comment('discussion_comment_deleted') if commentable_type == 'Discussion'
    delete_notifications
  end

  def delete_notifications
    PersonalNotification.where(issuer_id: id, issuer_type: self.class.name).update_all(body: 'Сообщение было удалено', issuer_id: nil, issuer_type: nil)
  end

  def can_edit?(commenter_id)
    commenter_id == account_id
  end

  def can_delete?(commenter_id)
    commenter_id == account_id
  end

  def serializable_hash(options = nil)
    h = super(options)
    if options&.fetch(:current_account_id, nil)
      h['can_edit'] = can_edit?(options[:current_account_id])
      h['can_delete'] = can_delete?(options[:current_account_id])
      h['already_liked'] = already_liked?(options[:current_account_id])
      h['read'] = commentable_type == 'Discussion' && (!commentable.member?(account_id) || (commentable&.last_read_at(options[:current_account_id]).present? && created_at <= commentable&.last_read_at(options[:current_account_id])))
    end
    h
  end

  private

  def update_discussion_last_at
    if commentable_type == 'Discussion' && !destroyed_by_association
      commentable.update(last_comment_at: commentable.last_comment_date || commentable.created_at)
    end
  end

  def parent_must_have_same_commentable
    if parent_comment_id
      errors.add(:parent_comment_id, 'Родительский комментарий должен принадлежать той-же сущности') unless parent_comment&.commentable == commentable
    end
  end

  def notify_users
    case commentable_type
    when 'NewsItem'
      PersonalNotificationsWorker.perform_async(account_id: parent_comment&.account_id, action_type: :news_item_comment_commented, issuer_json: to_issuer_json, initiator_id: RequestStore[:current_account]&.id) if parent_comment.present?
    when 'Post'
      PersonalNotificationsWorker.perform_async(account_id: parent_comment&.account_id, action_type: :post_comment_commented, issuer_json: to_issuer_json, initiator_id: RequestStore[:current_account]&.id) if parent_comment.present?
      PersonalNotificationsWorker.perform_async(account_id: commentable&.author_id, action_type: :post_commented, issuer_json: to_issuer_json, initiator_id: RequestStore[:current_account]&.id) if parent_comment.present?
    when 'Bid'
      PersonalNotificationsWorker.perform_async(account_id: commentable&.author&.id, action_type: :bid_commented, issuer_json: to_issuer_json, initiator_id: RequestStore[:current_account]&.id) if parent_comment.present?
    end
  end

  def update_candidate_history
    commentable&.candidate&.update_history('comment_added', created_at, commentable&.vacancy, self, account) if commentable_type == 'CandidateVacancy'
  end

  def ws_comment(type)
    account_ids = commentable&.discussers&.pluck :account_id
    RabbitSenderWorker.perform_async(account_ids.compact.uniq, { type: type },
                                     as_json(
                                       except: %i[user_id],
                                       include: {
                                         account: { methods: :full_name },
                                         photos: {},
                                         documents: {},
                                         deleted_by: {}
                                       }))
  end
end
