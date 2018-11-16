class Api::V0::Resources::TeamBuildingInformationAccountsController < Api::ResourceController

  def resource_collection
    @resource_collection ||= Bid.find(params[:bid_id]).team_building_information&.team_building_information_accounts
    raise ActiveRecord::AssociationNotFoundError, 'Данная заявка не является заявкой на тимбилдинг' if @resource_collection.nil?
    @resource_collection
  end

  def json_collection_inclusion
    @json_collection_inclusion ||= {
      only: %i[id],
      include: {
        account: {
          only: %i[id photo],
          methods: %i[full_name position_name phone city departments_chain]
        }
      }
    }
  end

  def chain_collection_inclusion
    @chain_collection_inclusion ||= [account: [:account_phones, :account_emails, :account_messengers, :preferred_email, :preferred_phone, default_legal_unit_employee: [legal_unit_employee_position: %i[department position]]]]
  end
end
