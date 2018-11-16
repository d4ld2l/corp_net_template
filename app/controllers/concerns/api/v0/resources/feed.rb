module Api::V0::Resources::Feed
  extend ActiveSupport::Concern

  included do

    private

    def chain_resource_inclusion
      @chain_resource_inclusion ||= [:taggings, :author, :community, :deleted_by, :likes, :documents, :photos, favorite_posts:[:account], comments:[:account, :children]]
    end

    def chain_collection_inclusion
      @chain_collection_inclusion ||= [:taggings, :author, :community, :deleted_by, :likes, :documents, :photos, favorite_posts:[:account], comments:[:account, :children]]
    end

    def json_collection_inclusion
      @json_collection_inclusion ||= {
          methods: [:likes_count, :comments_count, :comments_list, :tag_list],
          include: {author:{methods:[:full_name]}, community:{}, deleted_by:{methods:[:full_name]}, likes:{except:[:likable_id, :likable_type]}, documents:{}, photos:{}, comments:{ include:{ likes:{} } }},
          current_account_id: current_account.id
      }
    end

    def json_resource_inclusion
      @json_resource_inclusion ||= {
          methods: [:likes_count, :comments_count, :comments_list, :tag_list],
          include: {author:{methods:[:full_name]}, community:{}, deleted_by:{methods:[:full_name]}, likes:{except:[:likable_id, :likable_type]}, documents:{}, photos:{}},
          current_account_id: current_account.id
      }
    end
  end
end