class Api::V0::Resources::DepartmentsController < Api::ResourceController
  before_action :authenticate_user!

  def index
    render json: @collection.as_json()
  end

  def tree
    @legal_units = LegalUnit.all.as_json
    @legal_units.each do |x|
      departments_tree = Department.top_level.where(legal_unit_id: x['id']).decorate.map(&:to_node).as_json
      x.merge!({departments_tree:departments_tree})
    end
    render json: @legal_units
  end

  private

  def permitted_attributes
    [:company_id, :parent_id, :code, :name_ru, :region]
  end
end
