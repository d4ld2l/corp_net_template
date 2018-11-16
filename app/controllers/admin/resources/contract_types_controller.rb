class Admin::Resources::ContractTypesController < Admin::ResourceController
  include Paginatable

  private

  def permitted_attributes
    [:id, :name]
  end
end
