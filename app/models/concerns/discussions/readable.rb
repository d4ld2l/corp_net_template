module Discussions
  module Readable
    extend ActiveSupport::Concern
    included do
      has_many :account_reading_entities, as: :readable, dependent: :destroy
      scope :unread, ->(account_id) { left_joins(:account_reading_entities).where("(account_reading_entities.account_id = #{account_id} AND account_reading_entities.last_read_at < discussions.last_comment_at) OR NOT EXISTS(SELECT id FROM account_reading_entities WHERE account_reading_entities.account_id = #{account_id}) AND discussions.id IN (SELECT discussion_id FROM discussers WHERE discussers.account_id = #{account_id} AND discussers.left = false)") }

      after_create { read!(author_id, created_at) }
      after_create { update(last_comment_at: created_at) }

      def read!(account_id, id)
        account_reading_entities.find_or_create_by(account_id: account_id).update(last_read_at: comments.find_by_id(id)&.created_at || created_at)
      end

      def read_all!(account_id)
        account_reading_entities.find_or_create_by(account_id: account_id).update(last_read_at: comments.last&.created_at || created_at)
      end

      def read_discussion?(account_id)
        last_read_at(account_id) && created_at <= last_read_at(account_id)
      end

      def read_comments?(account_id)
        last_read_at(account_id) && last_comment_date <= last_read_at(account_id)
      end

      def last_comment_date
        @last_comment ||= comments.maximum(:created_at)
      end

      def last_read_at(account_id)
        @last_read_at ||= account_reading_entities.find_by(account_id: account_id)&.last_read_at
      end

      def read?(account_id)
        true unless member?(account_id)
        last_comment_date.present? ? read_discussion?(account_id) && read_comments?(account_id) : read_discussion?(account_id)
      end

      def count_unread(account_id)
        return 0 unless member?(account_id)
        cnt = read_discussion?(account_id) ? 0 : 1
        cnt += if last_read_at(account_id)
                 comments.where.not(account_id: account_id).where('created_at > (?)', last_read_at(account_id)).count
               else
                 comments.where.not(account_id: account_id).count
               end
        cnt
      end

      def page_of_last_read(account_id, per_page)
        return last_comments_page(per_page) unless member?(account_id)
        lr = last_read_at(account_id)
        return 1 if lr.nil?
        comment_id = comments.where('created_at <= (?)', last_read_at(account_id)).reorder(created_at: :desc).first&.id
        return 1 unless comment_id
        index = comments.reorder(created_at: :asc).pluck(:id).index(comment_id)
        index / per_page.to_i + 1
      end

      def last_comments_page(per_page)
        return 1 if comments.blank?
        (comments.count - 1) / per_page.to_i + 1
      end

      def mentioned?(account_id)
        (mentions.exists?(account_id: account_id) && !read_discussion?) || comments.joins(:mentions).where(mentions: { account_id: account_id }).where('comments.created_at > (?)', last_read_at(account_id)).any?
      end
    end
  end
end