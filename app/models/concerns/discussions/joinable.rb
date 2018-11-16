module Discussions
  module Joinable
    extend ActiveSupport::Concern

    included do
      has_many :discussers, -> { where left: false }, dependent: :destroy
      has_many :left_discussers, -> { where left: true }, dependent: :destroy, class_name: 'Discusser'
      has_many :all_discussers, dependent: :destroy, class_name: 'Discusser'

      after_create { discussers.create(account_id: author_id) }
      before_save :check_discussers

      has_many :accounts, through: :discussers
      accepts_nested_attributes_for :discussers, reject_if: :all_blank, allow_destroy: true

      scope :active, ->(account_id) { created_by_me(account_id).or(discussing(account_id)).distinct }
      scope :available, ->(account_id) { left_outer_joins(:all_discussers).where(available_to_all: true).where.not(author_id: account_id).where("discussions.id NOT IN (select discussers.discussion_id from discussers WHERE account_id = #{account_id})").distinct.or(left(account_id)) }
      scope :discussing, ->(account_id) { left_outer_joins(:all_discussers).where("discussers.account_id = #{account_id} AND discussers.left = false").distinct }
      scope :left, ->(account_id) { left_outer_joins(:all_discussers).where(available_to_all: false).where("discussers.account_id = #{account_id} AND discussers.left = true").distinct }
      scope :created_by_me, ->(account_id) { left_outer_joins(:all_discussers).where(author_id: account_id).distinct }
      scope :favorites, ->(account_id) { left_outer_joins(:all_discussers).where("discussers.account_id = #{account_id} AND discussers.faved = true").distinct }

      def join!(account_id)
        raise JoiningAuthoredDiscussion, 'Вы являетесь создателем этого обсуждения' if author_id == account_id
        discusser = all_discussers.find_or_initialize_by(account_id: account_id)
        if available_to_all?
          raise JoiningJoinedDiscussion, 'Вы уже являетесь участником этого обсуждения' if discusser.persisted?
          discusser.save!
          read_all!(account_id)
          ws_notify_discusser_changes([account_id], 'joined_public')
        elsif discusser.persisted?
          raise JoiningJoinedDiscussion, 'Вы уже являетесь участником этого обсуждения' unless discusser.left?
          discusser.left = false
          discusser.left_at = nil
          discusser.save!
          ws_notify_discusser_changes([account_id], 'joined_private')
        else
          raise JoiningProhibitedDiscussion, 'Вы не можете присоединиться к этому обсуждению'
        end
        create_message('joined', account_id: [account_id])
      end

      def leave!(account_id)
        raise LeavingAuthoredDiscussion, 'Вы являетесь создателем этого обсуждения' if author_id == account_id
        discusser = all_discussers.find_by(account_id: account_id)
        if discusser.blank? || discusser.left?
          raise LeavingUnjoinedDiscussion, 'Вы отсутствуете в этом обсуждении'
        end
        if available_to_all?
          discusser.destroy
          ws_notify_discusser_changes([account_id], 'left_public')
        else
          discusser.update(left: true, faved: false, left_at: Time.current)
          ws_notify_discusser_changes([account_id], 'left_private')
        end
        create_message('left', account_id: [account_id])
      end

      def member?(account_id)
        discussers.exists?(account_id: account_id)
      end

      def left_member?(account_id)
        !available_to_all? && left_discussers.exists?(account_id)
      end

      def remove_discussers!(account_ids)
        if available_to_all?
          raise RemovingFromPublicDiscussion, 'Вы не можете удалять из публичного обсуждения'
        else
          account_ids -= [author_id]
          discussers.where(account_id: account_ids).destroy_all
          ws_notify_discusser_changes(account_ids, 'removed')
          create_message('deleted', account_id: account_ids)
        end
      end

      def add_discussers!(account_ids)
        if available_to_all?
          raise AddingToPublicDiscussion, 'Вы не можете добавлять в публичное обсуждение'
        else
          account_ids -= discussers.pluck(:account_id)
          discussers.create(account_ids.map { |x| { account_id: x } })
          ws_notify_discusser_changes(account_ids, 'added')
          create_message('joined', account_id: account_ids)
        end
      end

      def faved?(account_id)
        discussers.exists?(account_id: account_id, faved: true)
      end

      def fav!(account_id)
        discussers.find_by(account_id: account_id)&.update(faved: true)
      end

      def unfav!(account_id)
        discussers.find_by(account_id: account_id)&.update(faved: false)
      end

      def check_discussers
        raise ActiveRecord::RecordInvalid, 'Вы уже являетесь создателем обсуждения' if discussers.reject(&:persisted?).map(&:account_id).any? { |x| x == author_id }
        raise ActiveRecord::RecordInvalid, 'Нельзя удалить автора' if discussers.select(&:marked_for_destruction?).any? { |x| x == author_id }
      end
    end

    class JoiningAuthoredDiscussion < StandardError

    end

    class JoiningJoinedDiscussion < StandardError

    end

    class JoiningProhibitedDiscussion < StandardError

    end

    class LeavingAuthoredDiscussion < StandardError

    end

    class LeavingUnjoinedDiscussion < StandardError

    end

    class AddingToPublicDiscussion < StandardError

    end

    class RemovingFromPublicDiscussion < StandardError

    end
  end
end