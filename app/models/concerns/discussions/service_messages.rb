module Discussions
  module ServiceMessages
    extend ActiveSupport::Concern
    included do
      before_update :message_renew_discussers
      before_update :inform_title_updated

      def create_message(type, params = {})
        case type
        when 'joined'
          comments.create(params[:account_id].map { |x| { account_id: x, body: 'присоединяется', service: true } })
        when 'left'
          comments.create(params[:account_id].map { |x| { account_id: x, body: 'покидает обсуждение', service: true } })
        when 'deleted'
          comments.create(params[:account_id].map { |x| { account_id: x, body: 'удаляют из обсуждения', service: true } })
        when 'name_changed'
          comments.create(account_id: params[:account_id], body: "меняет название на \"#{params[:new_name]}\"", service: true)
        end
      end

      def message_renew_discussers
        return if available_to_all?
        created = discussers.reject(&:persisted?).map(&:account_id)
        destroyed = discussers.select(&:marked_for_destruction?).map(&:account_id)
        create_message('deleted', account_id: destroyed) if destroyed.any?
        create_message('joined', account_id: created) if created.any?
      end

      def inform_title_updated
        create_message('name_changed', account_id: author_id, new_name: name) if changes.include?(:name)
      end
    end
  end
end
