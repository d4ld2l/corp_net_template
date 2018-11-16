class Api::V0::Resources::LegalUnitsController < Api::ResourceController
  include Api::V0::Resources::LegalUnits

  def dictionary
    @collection = LegalUnit.all
    render json: @collection.as_json(only:[:id, :name])
  end

  private

  def association_chain
    resource_collection.includes(chain_collection_inclusion).all.order(updated_at: :desc)
  end
end
