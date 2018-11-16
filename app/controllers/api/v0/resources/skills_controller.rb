class Api::V0::Resources::SkillsController < Api::ResourceController

  def index
    render json: @collection.uniq { |x| x[:name] }.as_json(only:[:id, :name])
  end

  private

  def permitted_attributes
    %i[name account_id project_id]
  end

end
