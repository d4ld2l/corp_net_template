module AasmStates
  extend ActiveSupport::Concern

  included do
    before_action :set_resource, only: %i[update show destroy allowed_states change_state]

    def states
      render json: resource_collection.aasm.states.map{ |s| s.name.to_s }
    end

    def allowed_states
      render json: @resource_instance.aasm.states(permitted: true).map{ |s| s.name.to_s }
    end

    def change_state
      response = if @resource_instance.apply_state(state_params[:state])
                   { success: true, resource_name => @resource_instance }
                 else
                   { success: false, resource_name => @resource_instance }
                 end

      render json: response
    end

    private

    def state_params
      allowed_states = resource_collection.aasm.states.map{ |s| s.name.to_s }

      params.permit(:id, :state, :subdomain, resource_name.to_sym => {})
      params.delete(:state) unless params[:state].in? allowed_states
      params
    end
  end
end