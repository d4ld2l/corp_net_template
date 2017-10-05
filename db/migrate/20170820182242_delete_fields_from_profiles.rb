class DeleteFieldsFromProfiles < ActiveRecord::Migration[5.0]
  def change
    remove_column :profiles, :email_work
    remove_column :profiles, :position
    remove_column :profiles, :phone_number_landline
    remove_column :profiles, :phone_number_corporate
    remove_column :profiles, :office_id
    remove_column :profiles, :manager_id
    remove_column :profiles, :department_code
    remove_column :profiles, :position_code
    remove_column :profiles, :department_head
  end
end
