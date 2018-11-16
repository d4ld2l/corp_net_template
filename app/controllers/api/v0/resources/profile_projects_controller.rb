class Api::V0::Resources::ProfileProjectsController < Api::ResourceController
  include Api::V0::Resources::ProfileProjects
  prepend_before_action :set_project
  before_action :set_resource, only: [:update, :show, :destroy, :repair]

  def index
    render json: {
        total: @total_count,
        active: @active_count,
        gone: @gone_count,
        profile_projects: @collection.page(page).per(per_page).as_json(json_collection_inclusion)
    }
  end

  def show
    render json: @resource_instance.as_json(json_resource_inclusion)
  end

  def create
    if @resource_instance.save
      render json: {success: true, profile_project:  @resource_instance.as_json(json_resource_inclusion)}
    else
      render json: {success: false, errors: @resource_instance.errors}
    end
  end

  def update
    if @resource_instance.update_attributes(resource_params)
      render json: {success: true, profile_project: @resource_instance.as_json(json_resource_inclusion)}
    else
      render json: {success: false, errors: @resource_instance.errors}
    end
  end

  def destroy
    unless @resource_instance.may_to_gone?
      return render json: {success:false, errors: ['Невозможно удалить участника']}
    end
    if @resource_instance.to_gone!
      render json: {success:true, profile_project:@resource_instance.as_json(json_resource_inclusion)}
    else
      render json: {success:false, errors: @resource_instance.errors}
    end
  end

  def repair
    unless @resource_instance.may_to_active?
      return render json: {success:false, errors: ['Невозможно восстановить участника']}
    end
    if @resource_instance.to_active!
      render json: {success:true, profile_project:@resource_instance.as_json(json_resource_inclusion)}
    else
      render json: {success:false, errors: @resource_instance.errors}
    end
  end

  private

  def association_chain
    super.includes(chain_collection_inclusion)
  end

  def by_scope(chain)
    if params[:scope] && %w[active gone].include?(params[:scope])
      chain.send("only_#{params[:scope]}")
    else
      chain
    end
  end

  def set_collection
    @collection ||= params[:q] ? search : association_chain
    @collection = @collection.where(project_id: @project_id)
    @collection = @collection.includes(:profile).reorder("profiles.surname asc")
    @total_count = @collection.count
    @active_count = @collection.where(status: 'active').count
    @gone_count = @collection.where(status: 'gone').count
    @collection = by_scope(@collection)
    instance_variable_set("@#{ collection_name }", @collection)
  end

  def search
    query = params[:q]&.dup.to_s[0..127]
    reserved_symbols = %w(+ - = && || > < ! ( ) { } [ ] ^ " ~ * ? : \\ /)
    reserved_symbols.each do |s|
      query.gsub!(s, "\\#{s}")
    end
    association_chain.search(query, size: 1000).records
  end

  def set_resource
    @resource_instance ||= ProfileProject.includes(chain_resource_inclusion).references(chain_resource_inclusion).where(id: params[:id], project_id: @project_id)&.first
    raise ActiveRecord::RecordNotFound.new(params[:path]) unless @resource_instance.present?
  end

  def set_project
    @project_id = params[:project_id]
    @project = Project.find(@project_id)
    raise ActiveRecord::RecordNotFound.new(params[:path]) unless @project_id.present?
  end

  def permitted_attributes
    [
      :id, :status, :profile_id, :project_id, project_work_periods_attributes:[
        :id, :begin_date, :end_date, :role, :duties, :_destroy
      ],
      profile_attributes: [ :id, skills_attributes: [:id, :name, :project_id] ]
    ]
  end
end
