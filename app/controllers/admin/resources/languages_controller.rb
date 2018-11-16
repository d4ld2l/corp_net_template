class Admin::Resources::LanguagesController < Admin::ResourceController
  include Paginatable

  # def index
  #   # if params[:sort_by] and not params[:q]
  #   #
  #   #   # if params[:sort_by] == 'count_specs'
  #   #   #   @collection = @collection
  #   #   #                     .left_joins(:professional_specializations)
  #   #   #                     .group(:id)
  #   #   #                     .reorder("COUNT(professional_specializations.id) #{@sort_order}")
  #   #   # else
  #   #   #   order_settings = params[:sort_by] + ' ' + @sort_order
  #   #   #   @collection = @collection.reorder(order_settings)
  #   #   # end
  #   #
  #   # end
  # end



  private

  def permitted_attributes
    [:id, :name]
  end
end
