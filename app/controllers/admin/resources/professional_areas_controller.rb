class Admin::Resources::ProfessionalAreasController < Admin::ResourceController
  include Paginatable

  private

  def permitted_attributes
    [:id, :name, professional_specializations_attributes: [:id, :name, :_destroy]]
  end
end
