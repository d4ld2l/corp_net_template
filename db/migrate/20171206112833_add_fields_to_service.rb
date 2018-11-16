class AddFieldsToService < ActiveRecord::Migration[5.0]
  def change
    add_column :services, :is_provided_them, :text
    add_column :services, :order_service, :text
    add_column :services, :results, :text
    add_column :services, :term_for_ranting, :text
    add_column :services, :restrictions, :text
  end
end
