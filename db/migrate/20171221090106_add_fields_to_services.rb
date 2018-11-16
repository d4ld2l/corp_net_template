class AddFieldsToServices < ActiveRecord::Migration[5.0]
  def change
    add_column :services, :supporting_documents, :text
    add_column :services, :show_notification, :boolean
  end
end
