class Admin::Resources::CustomersController < Admin::ResourceController
  include Paginatable

  private

  def permitted_attributes
    [:name]
  end
end
