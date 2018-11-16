class AddSocialUrlsToCustomerContacts < ActiveRecord::Migration[5.0]
  def change
    add_column :customer_contacts, :social_urls, :json, default: []
  end
end
