class Admin::Resources::MailingListsController < Admin::ResourceController
  include Paginatable
  before_action :set_collection_for_account_fields, only: %i[new edit]

  def create
    @resource_instance.creator ||= current_account
    super
  end

  def index 
    if params[:sort_by]  and not params[:q]
      if params[:sort_by] == 'count_participants'
        @collection = @collection
          .joins(profile_mailing_lists: :profile)
          .group(:id)
          .reorder("COUNT(profiles.id) #{@sort_order}")
      else 
        order_settings = params[:sort_by] + ' ' + @sort_order
        @collection = @collection.includes(creator: :profile).reorder(order_settings)
      end
    end  
  end

  def update
    if @resource_instance.update_attributes(resource_params)
      redirect_to @resource_instance, notice: "Сущность успешно обновлена"
    else
      render :edit, notice: 'Ошибка при заполнении. Проверьте наличие имени и отсутствие повторяющихся сотрудников в группе'
    end
  end

  private

  def set_collection_for_account_fields
    @account_fields_collection = Account.not_blocked.all.collect {|c| [c.full_name, c.id]}
  end

  def permitted_attributes
    super + [account_mailing_lists_attributes: [:account_id, :_destroy, :mailing_list_id, :id]]
  end
end
