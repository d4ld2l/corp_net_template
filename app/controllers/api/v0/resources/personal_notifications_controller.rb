class Api::V0::Resources::PersonalNotificationsController < Api::ResourceController
  before_action :authenticate_account!
  before_action :set_collection, only: %i[index mark_as_read]

  def index
    render json: { notifications: @collection.as_json(json_collection_inclusion),
                   total: PersonalNotification.by_account(current_account.id).where(read: false).count }
  end

  def mark_as_read
    if PersonalNotification.where(id: params[:id]).update(read: true)
      render json: { notifications: @collection.as_json(json_collection_inclusion),
                     total: PersonalNotification.by_account(current_account.id).where(read: false).count }
    else
      render json: { success: false }
    end
  end

  private

  def association_chain
    result = resource_collection.by_account(current_account.id)
    result = result.by_group(params[:group]) if params[:group] && resource_collection.group_types.include?(params[:group])
    result = result.by_module(params[:module]) if params[:module] && resource_collection.module_types.include?(params[:module])
    result.order(created_at: :desc).page(page).per(per_page)
  end

  def permitted_attributes
    []
  end

  def json_collection_inclusion
    { methods: :issuer, except: %i[issuer_id issuer_type] }
  end
end
