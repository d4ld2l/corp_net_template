class Admin::Resources::PositionsController < Admin::ResourceController
  include Paginatable

  private

  def permitted_attributes
    [:legal_unit_id, :code, :name_ru, :description, :position_group_code, :salary_from, :salary_up]
  end
end
