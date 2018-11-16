class PersonalNotification < ApplicationRecord
  belongs_to :account
  enum group_type: %i[common social business]
  enum module_type: %i[other news feed surveys services]

  scope :by_module, ->(x){where(module_type: x)}
  scope :by_group, ->(x){where(group_type: x)}
  scope :by_account, ->(x){where(account_id: x)}

  def self.notify_user(account_id, action_type, issuer_json, initiator_id = nil)
    issuer = get_issuer(issuer_json)
    action_type = action_type.to_sym
    issuer_result = json_from_issuer(issuer, action_type)
    PersonalNotification.create(account_id: account_id,
                                group_type: actions_hash[action_type][:group],
                                module_type: actions_hash[action_type][:module],
                                title: title_from_action(action_type, issuer, initiator_id),
                                body: body_from_issuer(issuer, action_type),
                                issuer_type: issuer_result[:type],
                                issuer_id: issuer_result[:id],
                                parent: issuer_result[:parent],
                                icon: Account.find_by_id(initiator_id)&.photo&.url) unless account_id == initiator_id
  end

  def issuer
    @issuer ||= {type: issuer_type, id: issuer_id, parent: parent}
  end

  private

  def self.get_issuer(issuer_json)
    issuer_json['type'].constantize.find_by(id: issuer_json['id'])
  end

  def self.json_from_issuer(issuer, action_type)
    hash = {type: issuer.class.name, id: issuer.id, parent: {}}
    case action_type
    when :news_item_comment_commented
      hash[:parent] = {type: issuer.commentable_type, id: issuer.commentable_id}
    when :news_item_comment_liked
      hash[:parent] = {type: issuer.likable_type, id: issuer.likable_id, parent: {type: issuer.likable.commentable_type, id: issuer.likable.commentable_id}}
    when :user_mentioned
      hash[:parent] = {type: issuer.post.class.name, id: issuer.post.id}
    when :post_liked
      hash[:parent] = {type: issuer.likable_type, id: issuer.likable_id}
    when :post_comment_liked
      hash[:parent] = {type: issuer.likable_type, id: issuer.likable_id, parent: {type: issuer.likable.commentable_type, id: issuer.likable.commentable_id}}
    when :post_comment_commented, :post_commented
      hash[:parent] = {type: issuer.commentable_type, id: issuer.commentable_id}
    when :bid_commented
      hash[:parent] = {type: issuer.commentable_type, id: issuer.commentable_id}
    else
      hash[:parent] = nil
    end
    hash
  end

  def self.body_from_issuer(issuer, action_type)
    case action_type
    when :news_item_comment_commented, :post_comment_commented, :post_commented, :bid_commented
      return issuer&.body || ''
    when :user_mentioned
      return issuer&.post&.body || ''
    when :survey_published
      return issuer&.ends_at.present? ? "Опрос необходимо пройти до #{I18n.l issuer&.ends_at}" : ""
    when :bid_status_changed
      return "Сервис #{issuer&.service&.name}"
    else
      return ""
    end
  end

  def self.actions_hash
    {
        news_item_comment_commented: {group: :social, module: :news},
        news_item_comment_liked: {group: :social, module: :news},
        user_mentioned: {group: :social, module: :feed},
        post_liked: {group: :social, module: :feed},
        post_comment_liked: {group: :social, module: :feed},
        post_comment_commented: {group: :social, module: :feed},
        post_commented: {group: :social, module: :feed},
        survey_published: {group: :business, module: :surveys},
        your_survey_unpublished: {group: :business, module: :surveys},
        survey_going_to_unpublish: {group: :business, module: :surveys},
        bid_status_changed: {group: :business, module: :services},
        bid_commented: {group: :business, module: :services}
    }
  end

  def self.title_from_action(action_type, issuer, initiator_id = nil)
    initiator = Account.find_by_id(initiator_id)
    title = ""
    title += "@[#{initiator.full_name}](#{initiator_id}) " if initiator_id.present?
    case action_type
    when :news_item_comment_commented
      title += "ответил(а) на ваш комментарий \"#{san(issuer&.parent_comment&.body)&.truncate(40)}\" к новости \"#{issuer&.commentable&.title}\""
    when :news_item_comment_liked
      title += "оценил(а) ваш комментарий \"#{san(issuer&.likable&.body)&.truncate(40)}\" к новости \"#{issuer&.likable&.commentable&.title}\""
    when :user_mentioned
      title += "упомянул(а) вас в публикации \"#{san(issuer&.post&.body)&.truncate(40)}\""
    when :post_liked
      title += "оценил(а) вашу публикацию \"#{san(issuer&.likable&.body)&.truncate(40)}\""
    when :post_comment_liked
      title += "оценил(а) ваш комментарий \"#{san(issuer&.likable&.body)&.truncate(40)}\" к публикации \"#{san(issuer&.likable&.commentable&.body)&.truncate(40)}\""
    when :post_comment_commented
      title += "ответил(а) на ваш комментарий \"#{san(issuer&.parent_comment&.body)&.truncate(40)}\" к публикации \"#{san(issuer&.commentable&.body)&.truncate(40)}\""
    when :post_commented
      title += "оставил(а) комментарий под вашей публикацией \"#{san(issuer&.commentable&.body)&.truncate(40)}\""
    when :survey_published
      title = "Опубликован опрос \"#{issuer&.name}\", который вам необходимо пройти"
    when :your_survey_unpublished
      title = "Ваш опрос \"#{issuer&.name}\" автоматически снят с публикации #{I18n.l issuer&.ends_at}"
    when :survey_going_to_unpublish
      title = "Опрос \"#{issuer&.name}\", который вам необходимо пройти будет снят с публикации #{I18n.l issuer&.ends_at}"
    when :bid_status_changed
      title = "На вас назначена заявка номер #{issuer&.id}"
    when :bid_commented
      title = "Ваша заявка номер #{issuer&.commentable&.id} прокомментирована"
    else
      title = ""
    end
    title
  end

  def self.san(str)
    ActionView::Base.full_sanitizer.sanitize(str)
  end
end
