class AddsCommentsCountToCustomerContacts < ActiveRecord::Migration[5.0]
  def change
    add_column :customer_contacts, :comments_count, :integer, default: 0
  end
end
