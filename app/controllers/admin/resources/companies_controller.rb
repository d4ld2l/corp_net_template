class Admin::Resources::CompaniesController < Admin::ResourceController
  include Paginatable

  private

  def permitted_attributes
    [:name]
  end
end
