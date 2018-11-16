module Discussions
  module Ws
    extend ActiveSupport::Concern

    included do
      after_create_commit :ws_new_topic
      before_destroy :ws_destroy_topic
      before_update :ws_renew_discussers
      before_update :ws_topic_updated, if: :only_topic_updated?

      private

      def ws_new_topic
        account_ids, type = available_to_all? ? [(Account.not_blocked.ids - [author_id]), 'discussion_available'] : [(discussers.pluck(:account_id) - [author_id]), 'discussion_active']
        RabbitSenderWorker.perform_async(account_ids,
                                         { type: type },
                                         as_json(
                                           include: {
                                             author: {
                                               methods: [:full_name]
                                             },
                                             photos: {},
                                             documents: {},
                                             discussers: { include: :account }
                                           },
                                           except: [:comments_count],
                                           methods: [:messages_count]
                                         ))
        RabbitSenderWorker.perform_async([author_id],
                                         { type: 'discussion_active' },
                                         as_json(
                                           include: {
                                             author: {
                                               methods: [:full_name]
                                             },
                                             photos: {},
                                             documents: {},
                                             discussers: { include: :account }
                                           },
                                           except: [:comments_count],
                                           methods: [:messages_count]
                                         ))
      end

      def ws_renew_discussers
        return if available_to_all?
        created = discussers.reject(&:persisted?).map(&:account_id)
        destroyed = discussers.select(&:marked_for_destruction?).map(&:account_id)
        observed = discussers.pluck(:account_id) - created - destroyed
        RabbitSenderWorker.perform_async(observed, { type: 'discussion_updated' }, as_json(
          include: {
            author: {
              methods: [:full_name]
            },
            photos: {},
            documents: {},
            discussers: { include: :account }
          },
          except: [:comments_count],
          methods: [:messages_count]
        ))
        RabbitSenderWorker.perform_async(created,
                                         { type: 'discussion_active' },
                                         as_json(
                                           include: {
                                             author: {
                                               methods: [:full_name]
                                             },
                                             photos: {},
                                             documents: {},
                                             discussers: { include: :account }
                                           },
                                           except: [:comments_count],
                                           methods: [:messages_count]
                                         ))
        RabbitSenderWorker.perform_async(destroyed, { type: 'discussion_deleted' }, as_json(only: :id))
      end

      def ws_notify_discusser_changes(changed, type)
        case type
        when 'added'
          RabbitSenderWorker.perform_async(changed,
                                           { type: 'discussion_active' },
                                           as_json(
                                             include: {
                                               author: {
                                                 methods: [:full_name]
                                               },
                                               photos: {},
                                               documents: {},
                                               discussers: { include: :account }
                                             },
                                             except: [:comments_count],
                                             methods: [:messages_count]
                                           ))
        when 'removed'
          RabbitSenderWorker.perform_async(changed,
                                           { type: 'discussion_deleted' },
                                           as_json(only: :id))
        when 'joined_private', 'joined_public'
          RabbitSenderWorker.perform_async(changed,
                                           { type: 'discussion_active' },
                                           as_json(
                                             include: {
                                               author: {
                                                 methods: [:full_name]
                                               },
                                               photos: {},
                                               documents: {},
                                               discussers: { include: :account }
                                             },
                                             except: [:comments_count],
                                             methods: [:messages_count]
                                           ))
        when 'left_private', 'left_public'
          RabbitSenderWorker.perform_async(changed,
                                           { type: 'discussion_available' },
                                           as_json(
                                             include: {
                                               author: {
                                                 methods: [:full_name]
                                               },
                                               photos: {},
                                               documents: {},
                                               discussers: { include: :account }
                                             },
                                             except: [:comments_count],
                                             methods: [:messages_count]
                                           ))
        end
        observers = discussers.pluck(:account_id) - changed
        RabbitSenderWorker.perform_async(observers, { type: 'discussion_updated' }, as_json(
          include: {
            author: {
              methods: [:full_name]
            },
            photos: {},
            documents: {},
            discussers: { include: :account }
          },
          except: [:comments_count],
          methods: [:messages_count]
        ))
      end

      def ws_topic_updated
        account_ids = discussers.pluck(:account_id)
        RabbitSenderWorker.perform_async(account_ids, { type: 'discussion_updated' }, as_json(
          include: {
            author: {
              methods: [:full_name]
            },
            photos: {},
            documents: {},
            discussers: { include: :account }
          },
          except: [:comments_count],
          methods: [:messages_count]
        ))
      end

      def ws_destroy_topic
        account_ids = available_to_all? ? Account.not_blocked.ids : discussers.pluck(:account_id)
        RabbitSenderWorker.perform_async(account_ids, { type: 'discussion_deleted' }, as_json(only: :id))
      end

      def only_topic_updated?
        !changed.blank? && changed.any? { |x| ['name', 'body', 'author_id', 'available_to_all', 'state', 'likes_count', 'logo'].include?(x.to_s) }
      end
    end
  end
end
