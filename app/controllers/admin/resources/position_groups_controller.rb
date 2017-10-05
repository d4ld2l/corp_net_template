class Admin::Resources::PositionGroupsController < Admin::ResourceController
  include Paginatable

  private

  def permitted_attributes
    [:legal_unit_id, :code, :name_ru, :description, positions_attributes:
        [:id, :legal_unit_id, :code, :name_ru, :description, :position_group_code,
         :salary_from, :salary_up, :_destroy]
    ]
  end
end
