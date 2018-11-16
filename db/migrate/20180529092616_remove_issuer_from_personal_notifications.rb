class RemoveIssuerFromPersonalNotifications < ActiveRecord::Migration[5.0]
  def change
    remove_column :personal_notifications, :issuer, :json
    add_column :personal_notifications, :issuer_type, :string
    add_column :personal_notifications, :issuer_id, :integer
    add_index :personal_notifications, [:issuer_type, :issuer_id]
    add_column :personal_notifications, :parent, :json
  end
end
