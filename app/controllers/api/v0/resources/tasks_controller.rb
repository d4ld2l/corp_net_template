class Api::V0::Resources::TasksController < Api::ResourceController
  before_action :set_resource, only: %i[update show destroy]
  before_action :set_collection, only: :index

  def index
    render json: { count: resource_collection.counters(current_account.id), tasks: @collection.as_json(json_collection_inclusion) }
  end

  def create
    if @resource_instance.save
      render json: @resource_instance.reload.as_json(json_resource_inclusion)
    else
      render json: { success: false, errors: @resource_instance.errors.as_json }
    end
  end

  def update
    if @resource_instance.update_attributes(resource_params)
      render json: @resource_instance.reload.as_json(json_resource_inclusion)
    else
      render json: { success: false, errors: @resource_instance.errors.as_json }
    end
  end

  private

  def association_chain
    result = case params[:status]
             when 'finished'
               resource_collection.roots.finished
             when 'in_progress'
               resource_collection.roots.in_progress
             else
               resource_collection.roots
             end
    if %w[available_to_me created_by_me executed_by_me].include? params[:scope]
      result = result.send(params[:scope], current_account.id)
    else
      result = result.available_to_me(current_account.id)
    end
    result.includes(chain_collection_inclusion).ordered.page(page).per(per_page)
  end

  def permitted_attributes
    [:title, :description, :priority, :author_id, :displayed_in_calendar, :done, :executed_at, :ends_at, :executor_id, task_observers_attributes: %i[id account_id _destroy], subtasks_attributes: [:id, :_destroy, :title, :done, :priority, :executor_id, :executed_at, task_observers_attributes: [:account_id]]]
  end

  def set_resource
    @resource_instance ||= resource_collection.includes(chain_resource_inclusion).roots.find(params[:id])
    raise ActiveRecord::RecordNotFound, params[:path] unless @resource_instance.present?
  end

  def resource_collection
    if %w[surveys candidates bids vacancies events projects mailing_lists].include? params[:entity_type]
      @resource_collection ||= params[:entity_type].singularize.classify.constantize.find(params[:entity_id]).tasks
    else
      @resource_collection ||= resource_name.classify.constantize
    end
  end

  def json_resource_inclusion
    @json_resource_inclusion ||= { include: { executor: { methods: %i[full_name position_name] },
                                              author: { methods: %i[full_name position_name] },
                                              task_observers: { include: { account: { methods: %i[full_name position_name] } } },
                                              subtasks_available_to_account: { include: { executor: { methods: %i[full_name position_name] },
                                                                                          author: { methods: %i[full_name position_name] },
                                                                                          task_observers: { include: { account: { methods: %i[full_name position_name] } } } },
                                                                               except: [:total_subtasks_count, :executed_subtasks_count]
                                              },
                                              taskable:{} } }
  end

  def json_collection_inclusion
    @json_collection_inclusion ||= {include: {executor: {methods: %i[full_name position_name]},
                                              author: {methods: %i[full_name position_name]},
                                              task_observers: {include: {account: {methods: %i[full_name position_name]}}},
                                              taskable: { only: %i[id name title full_name]} }
    }
  end

  def chain_collection_inclusion
    @chain_collection_inclusion ||= [:executor, :author, :taskable,  task_observers: :account]
  end

  def chain_resource_inclusion
    @chain_resource_inclusion ||= [:executor, :author, :taskable, task_observers: :account, subtasks: [:executor, :author, task_observers: :account]]
  end
end
