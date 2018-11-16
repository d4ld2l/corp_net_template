class ContactsService < ApplicationRecord
  belongs_to :service
  belongs_to :contact, class_name: 'Account'
end
