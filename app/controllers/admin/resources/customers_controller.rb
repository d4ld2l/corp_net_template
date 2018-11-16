class Admin::Resources::CustomersController < Admin::ResourceController
  include Paginatable

  private

  def permitted_attributes
    [:name,
     counterparties_attributes:[:id, :name, :position, :responsible, :_destroy],
     customer_contacts_attributes: [
         :id, :name, :city, :position, :description, :skype, :_destroy, :social_urls_string, social_urls:[],
         contact_emails_attributes:[:id, :kind, :email, :preferable, :_destroy],
         contact_phones_attributes:[:id, :kind, :number, :preferable, :whatsapp, :telegram, :viber, :_destroy],
         contact_messengers_attributes:[:id, :name, :_destroy, :phones_string, phones:[]]
     ]
    ]
  end
end
