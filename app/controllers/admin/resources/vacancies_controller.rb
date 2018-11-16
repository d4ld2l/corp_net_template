class Admin::Resources::VacanciesController < Admin::ResourceController
  include Paginatable

  def index 
    if params[:sort_by] and not params[:q]
      if params[:sort_by] == 'recruiter_name'
        @collection = @collection
          .includes(owner: :profile)
          .reorder("profiles.surname #{@sort_order}")          
      elsif params[:sort_by] == 'manager_name'
        @collection = @collection
        .includes(creator: :profile)
        .reorder("profiles.surname #{@sort_order}")   
      else 
        order_settings = params[:sort_by] + ' ' + @sort_order
        @collection = @collection.reorder(order_settings)
      end
    end  
  end

end
