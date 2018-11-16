module Admin::SortableIndexHelper
  def sortable_header(link_name, sort_by_what)
    contr_sym = controller_name.parameterize.underscore.to_sym
    link_to link_name, controller: contr_sym, action: 'index', sort_by: sort_by_what, sort_order: @sort_order, q: @last_search_query
  end
end
