module Api::V0::Resources::Transactions
  extend ActiveSupport::Concern

  included do

    private

    def chain_resource_inclusion
      @chain_resource_inclusion ||= [
        account_achievement: [achievement: [:achievement_group]]
      ]
    end

    def chain_collection_inclusion
      @chain_collection_inclusion ||= [
        account_achievement: [achievement: [:achievement_group]]
      ]
    end

    def json_collection_inclusion
      @json_collection_inclusion ||= {
        include: {
          account_achievement: {
            achievement: {
              except: [:photo],
              include: { achievement_group: {} }
            }
          }
        }
      }
    end

    def json_resource_inclusion
      @json_resource_inclusion ||= {
        include: {
          profile_achievement: {
            achievement: {
              except: [:photo],
              include: { achievement_group: {} }
            }
          }
        }
      }
    end
  end
end