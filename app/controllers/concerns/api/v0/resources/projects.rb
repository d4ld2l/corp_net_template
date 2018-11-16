module Api::V0::Resources::Projects
  extend ActiveSupport::Concern

  included do
    private

    def chain_resource_inclusion
      @chain_resource_inclusion ||= [:customers, :legal_unit, :products, :methodologies, :technologies,
                                     manager: [],
                                     department: [:parent], customer_projects: [:customer]]
    end

    def chain_collection_inclusion
      @chain_collection_inclusion ||= [:customers, :manager, :taggings, :products, :methodologies, :technologies, customer_projects: [:customer]]
    end

    def json_collection_inclusion
      @json_collection_inclusion ||= {
        methods: [:accounts_count],
        include: {
          customers: {},
          customer_projects: { include: { customer: {} } },
          products: { only: :name }, technologies: { only: :name },
          manager: { methods: %i[full_name departments_chain], only: %i[id photo] }
        },
        except: %i[product_list technology_list methodology_list]
      }
    end

    def json_resource_inclusion
      @json_resource_inclusion ||= {
        methods: [:accounts_count],
        include: {
          legal_unit: {},
          department: { include: { parent: {} } },
          customers: {},
          products: { only: :name }, technologies: { only: :name }, methodologies: { only: :name },
          customer_projects: { include: { customer: {} } },
          account_projects: { only: %i[id account_id] },
          manager: { methods: %i[full_name departments_chain position_name preferred_phone preferred_email],
                     only: %i[id photo skype] }
        }
      }
    end
  end
end
