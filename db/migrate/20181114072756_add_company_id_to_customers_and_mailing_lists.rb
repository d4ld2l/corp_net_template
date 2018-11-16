class AddCompanyIdToCustomersAndMailingLists < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :company_id, :bigint, index: true
    add_column :mailing_lists, :company_id, :bigint, index: true
  end
end
