module Api::V0::Resources::Customers
  extend ActiveSupport::Concern

  included do

    private

    def chain_resource_inclusion
      @chain_resource_inclusion ||= %i[responsible_counterparty non_responsible_counterparties]
    end

    def chain_collection_inclusion
      @chain_collection_inclusion ||= %i[responsible_counterparty non_responsible_counterparties]
    end

    def json_collection_inclusion
      @json_collection_inclusion ||= {
        include: {
          responsible_counterparty: {
            except: %i[customer_id responsible]
          },
          non_responsible_counterparties: {
            except: %i[customer_id responsible]
          }
        }
      }
    end

    def json_resource_inclusion
      @json_resource_inclusion ||= {
        include: {
          responsible_counterparty: {
            except: %i[customer_id responsible]
          },
          non_responsible_counterparties: {
            except: %i[customer_id responsible]
          }
        }
      }
    end
  end
end