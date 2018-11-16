class Api::V0::Resources::MailingListsController < Api::ResourceController

  private

  def permitted_attributes
    [:name, :account_id, :description, :id, :importable_id, :importable_type, account_mailing_lists_attributes: %i[id account_id _destroy]]
  end

  def association_chain
    super.available_for_account(current_account.id)
  end

  def chain_collection_inclusion
    [account_mailing_lists: [account: [default_legal_unit_employee: [:position]]], creator: []]
  end

  def chain_resource_inclusion
    [account_mailing_lists: [account: [default_legal_unit_employee: [:position]]], creator: []]
  end

  def json_collection_inclusion
    @json_collection_inclusion ||= {
      include: {
        creator: {},
        account_mailing_lists: {
          include: {
            account: {
              methods: %i[departments_chain full_name position_name]
            }
          }
        }
      }
    }
  end

  def json_resource_inclusion
    @json_resource_inclusion ||= {
      include: {
        creator: {},
        account_mailing_lists: {
          include: {
            account: {
              methods: %i[departments_chain full_name position_name]
            }
          }
        }
      }
    }
  end
end
