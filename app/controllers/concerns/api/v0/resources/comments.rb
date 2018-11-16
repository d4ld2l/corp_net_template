module Api::V0::Resources::Comments
  extend ActiveSupport::Concern

  included do

    private

    def chain_resource_inclusion
      @chain_resource_inclusion ||= %i[children account likes]
    end

    def chain_collection_inclusion
      @chain_collection_inclusion ||= %i[children account likes]
    end

    def json_collection_inclusion
      @json_collection_inclusion ||= {
        methods: [:likes_count],
        except: %i[user_id commentable_type commentable_id],
        include: {
          children: {
            methods: [:likes_count],
            except: %i[user_id commentable_type commentable_id],
            include: { account: { methods: [:full_name] }, likes: {} },
            current_account_id: current_account.id
          },
          account: { methods: [:full_name] },
          likes: {}
        },
        current_account_id: current_account.id
      }
    end

    def json_resource_inclusion
      @json_resource_inclusion ||= {
        methods: [:likes_count],
        except: %i[user_id commentable_type commentable_id],
        include: { children: { methods: [:likes_count], except: %i[user_id commentable_type commentable_id], include: { account: { methods: [:full_name] }, likes: {} },
                               current_account_id: current_account.id }, account: { methods: [:full_name] }, likes: {} },
        current_account_id: current_account.id
      }
    end
  end
end