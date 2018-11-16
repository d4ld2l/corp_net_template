class AddCompanyIdToEventTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :event_types, :company_id, :bigint, index: true
  end
end
