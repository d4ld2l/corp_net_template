module Api::V0::Resources::News
  extend ActiveSupport::Concern

  included do

    private

    def chain_resource_inclusion
      @chain_resource_inclusion ||= [
        :taggings, :tags, :news_category, :community, :documents, :photos, :likes, :author,
        comments: [:account, :likes, children: [:likes]]
      ]
    end

    def chain_collection_inclusion
      @chain_collection_inclusion ||= [
        :news_category, :community, :documents, :photos, :likes, :author,
        comments: [:account, :likes, children: [:likes]]
      ]
    end

    def json_collection_inclusion
      @json_collection_inclusion ||= {
        methods: [:likes_count, :comments_count, :comments_list, :tags, :author],
        include: {
          tags: {}, news_category: {}, community: {}, documents: {}, photos: {},
          likes: { except: [:likable_id, :likable_type] }
        },
        current_account_id: current_account.id,
        except: [:tag_list]
      }
    end

    def json_resource_inclusion
      @json_resource_inclusion ||= {
        methods: [:likes_count, :comments_count, :comments_list, :tags],
        include: {
          tags: {}, news_category: {}, community: {}, documents: {}, photos: {},
          likes: { except: [:likable_id, :likable_type] }
        },
        current_account_id: current_account.id
      }
    end
  end
end