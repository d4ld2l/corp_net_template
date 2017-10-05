class Admin::Resources::DepartmentsController < Admin::ResourceController
  include Paginatable
  private

  def permitted_attributes
    [:legal_unit_id, :company_id, :parent_id, :code, :name_ru, :region, :manager_id, :logo]
  end
end
