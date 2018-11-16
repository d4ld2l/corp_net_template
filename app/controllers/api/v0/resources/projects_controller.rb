class Api::V0::Resources::ProjectsController < Api::ResourceController
  include Api::V0::Resources::Projects

  def dictionary
    render json: Project.all.order(created_at: :desc).as_json(only: %i[id charge_code title])
  end

  def index
    render json: {
      total: @total_count,
      my_projects_count: @only_my_count,
      current: @current_count,
      projects: @collection.page(page).per(per_page).as_json(json_collection_inclusion)
    }
  end

  def show
    render json: @resource_instance.as_json(json_resource_inclusion)
  end

  def create
    if @resource_instance.save
      render json: @resource_instance.as_json(json_resource_inclusion)
    else
      render json: { success: false, errors: @resource_instance.errors }
    end
  end

  def update
    if @resource_instance.update_attributes(resource_params)
      render json: @resource_instance.as_json(json_resource_inclusion)
    else
      render json: { success: false, errors: @resource_instance.errors }
    end
  end

  private

  def association_chain
    super.includes(chain_collection_inclusion)
  end

  def search
    query = params[:q]&.dup.to_s[0..127]
    reserved_symbols = %w(+ - = && || > < ! ( ) { } [ ] ^ " ~ * ? : \\ /)
    reserved_symbols.each do |s|
      query.gsub!(s, "\\#{s}")
    end
    resource_collection.search(query, size: 1000).records.includes(chain_collection_inclusion).distinct
  end

  def filter(chain)
    res = chain
    params.each do |p, val|
      res = res.where("#{p}": val) if %w[legal_unit_id manager_id].include?(p)
      if p == 'begin_date'
        res = res.where('begin_date >= ? or begin_date < ? and end_date >= ?', val, val, val)
      end
      if p == 'end_date'
        res = res.where('begin_date <= ? and end_date >= ? or end_date <= ?', val, val, val)
      end
      res = res.where(department_id: val.split(',')) if p == 'department_ids'
      if p == 'customer_id'
        res = res.includes(:customer_projects).where(customer_projects: { customer_id: val })
      end
      if %w[technologies products methodologies].include?(p)
        res = res.tagged_with(val, on: p, any: true)
      end
      res = res.where(status: val) if p == 'status'
    end
    res
  end

  def set_collection
    @collection ||= params[:q] ? search : association_chain
    @collection = filter(@collection)
    @total_count = @collection.size
    if params[:only_my]
      @collection = @collection.available_for(current_account.id)
    end
    @current_count = @collection.size
    @only_my_count = @collection.available_for(current_account.id).size
    instance_variable_set("@#{collection_name}", @collection)
  end

  def permitted_attributes
    [
      :status, :title, :charge_code, :legal_unit_id, :manager_id, :department_id, :begin_date, :end_date,
      :description, :all_employees,
      product_list: [], technology_list: [], methodology_list: [],
      customer_projects_attributes: %i[id customer_id _destroy],
      account_projects_attributes: %i[id account_id _destroy]
    ]
  end
end
