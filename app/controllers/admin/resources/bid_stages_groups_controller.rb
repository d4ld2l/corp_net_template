class Admin::Resources::BidStagesGroupsController < Admin::ResourceController
  attr_accessor :current_step
  helper_method :steps, :first_step?, :last_step?, :previous_step, :goto, :next_button_text, :current_bid_stages_group, :validate?

  STEPS = 1..3

  before_action :set_resource, except: :index
  before_action :set_current_step, only: %i[new edit]

  layout false, only: %i[create update]

  def create
    change_resource_by_step do
      @current_step == STEPS.last ? redirect_to(@resource_instance) : render
    end
  end

  def update
    change_resource_by_step do
      render js: "window.location.replace('#{bid_stages_group_path(@resource_instance)}')"
    end
  end

  def from
    @from ||= params[:from].to_i if params[:from].present?
  end

  def goto
    @goto ||= if params[:goto].present?
                params[:goto].to_i
              elsif params[:save].present?
                params[:save].to_i
              end
  end

  def next_step
    @current_step.next
  end

  def previous_step
    @current_step.pred
  end

  def last_step?
    @current_step == steps.last
  end

  def first_step?
    @current_step == steps.first
  end

  def validate?
    @validate ||= serialize_validate_params
  end

  def steps
    STEPS
  end

  def current_bid_stages_group
    return nil unless account_signed_in?

    @_current_bid_stages_group ||= @resource_instance

    if @_current_bid_stages_group.persisted?
      @_current_bid_stages_group.save(validate: validate?)
      @_current_bid_stages_group = @_current_bid_stages_group
    end

    @_current_bid_stages_group
  end

  private

  def change_resource_by_step
    return jump_to(goto, "step_#{from}".to_sym) if goto
    @resource_instance.assign_attributes(resource_params)

    if @resource_instance.save(context: ["step_#{from}".to_sym, action_name.to_sym])
      from == STEPS.last ? @current_step = from : @current_step = from&.next
      @resource_instance.save if from == STEPS.last

      yield
    else
      @resource_instance.save(validate: validate?)
      @current_step = from
      render
    end
  end

  def jump_to(goto, context)
    @resource_instance.assign_attributes(resource_params)
    @current_step = @resource_instance.save(context: [context, action_name.to_sym]) ? goto : context.to_s.last.to_i
    render
  rescue ActionController::ParameterMissing
    @current_step = goto
    render
  end

  def next_button_text
    last_step? ? t('controls.send') : t('controls.next')
  end

  def set_current_step
    @current_step = (params[:step] || 1).to_i
  end

  def serialize_validate_params
    params[:validate] == 'true' ? true : false
  end

  def set_resource
    @resource_instance ||= resource_collection.find(params[:id])
    instance_variable_set("@#{ resource_name }", @resource_instance)
  rescue ActiveRecord::RecordNotFound
    @resource_instance ||= resource_collection.new(resource_params || {})
    instance_variable_set("@#{ resource_name }", @resource_instance)
  end

  def permitted_attributes
    [:code, :name, :initial_executor, :initial_notification, initial_notifiable: [], bid_stages_attributes: [:id, :_destroy, :code, :name, :initial,
                                           allowed_bid_stages_attributes: [:id, :_destroy, :allowed_stage_id, :executor,
                                                                           :name_for_button, :current_stage_id, :additional_executor_id,
                                                                           :notification, notifiable: [], bids_executor_ids: []]]]
  end
end
