class Api::V0::Resources::TransactionsController < Api::ResourceController
  include Api::V0::Resources::Transactions

  private

  def association_chain
    super.where(recipient_id: params[:account_id]).includes(chain_collection_inclusion)
  end

  def permitted_attributes
    []
  end
end
