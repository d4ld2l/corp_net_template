class Api::V0::Resources::SubtasksController < Api::ResourceController
  before_action :authenticate_account!
  before_action :set_resource, only: %i[update show destroy]

  private

  def set_resource
    @resource_instance ||= Task.roots.available_to_me(current_account.id).find(params[:task_id]).subtasks_available_to_account.includes(chain_resource_inclusion).find(params[:id])
  end

  def set_collection
    @collection ||= resource_collection
  end

  def resource_collection
    @resource_collection ||= Task.roots.available_to_me(current_account.id).find(params[:task_id]).subtasks_available_to_account.includes(chain_collection_inclusion)
  end

  def subtask_params
    params.require(:subtask).permit(:title, :description, :done, :priority, :executor_id, :executed_at, :displayed_in_calendar, task_observers_attributes: [:account_id, :id, :_destroy])
  end

  def json_resource_inclusion
    @json_resource_inclusion ||= { include: { executor: { methods: %i[full_name position_name] },
                                              author: { methods: %i[full_name position_name] },
                                              task_observers: { include: { account: { methods: %i[full_name position_name] } } } },
                                   except: [:total_subtasks_count, :executed_subtasks_count] }
  end

  def json_collection_inclusion
    @json_collection_inclusion ||= { include: { executor: { methods: %i[full_name position_name] },
                                                author: { methods: %i[full_name position_name] },
                                                task_observers: { include: { account: { methods: %i[full_name position_name] } } } },
                                     except: [:total_subtasks_count, :executed_subtasks_count] }
  end

  def chain_collection_inclusion
    @chain_collection_inclusion ||= [executor: [], author: [], task_observers: :account]
  end

  def chain_resource_inclusion
    @chain_resource_inclusion ||= [executor: [], author: [], task_observers: :account]
  end

  def build_resource
    @resource_instance = Task.roots.find(params[:task_id]).subtasks.build(subtask_params)
  end
end
