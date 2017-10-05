class Api::V0::Resources::UsersController < Api::ResourceController
  include ActionController::ImplicitRender

  before_action :authenticate_user!

  def index
    # @q = User.ransack(params[:q])
    # @collection = @q.result()
    # if params[:role]
    #   render json: @collection.includes(:role).where(roles: {name: params[:role]}).as_json(include: :profile)
    # else
    #   render json: @collection.as_json(include: :profile)
    # end
    pp current_user
    render :index, as: :json, layout: false
  end

  def show
    render json: @resource_instance.as_json(include: :profile)
  end

  private

  def permitted_attributes
    [:email, :password, :password_confirmation, :role_id]
  end

end
