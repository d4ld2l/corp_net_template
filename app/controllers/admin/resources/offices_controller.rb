class Admin::Resources::OfficesController < Admin::ResourceController
  include Paginatable

  private

  def permitted_attributes
    [:name]
  end
end
