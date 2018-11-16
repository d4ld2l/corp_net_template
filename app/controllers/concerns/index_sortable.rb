module IndexSortable
  extend ActiveSupport::Concern

  def change_sort_order
    params[:q]&.permit! if params[:q].respond_to?(:permit!)
    @last_search_query = params[:q]
    @sort_order = params[:sort_order] == 'DESC' ? 'ASC' : 'DESC'
  end
end
