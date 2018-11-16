class Api::V0::Resources::CustomersController < Api::ResourceController
  include Api::V0::Resources::Customers

  private

  def permitted_attributes
    [:id, :name,
     counterparties_attributes: %i[id name position responsible _destroy]
    ]
  end
end
