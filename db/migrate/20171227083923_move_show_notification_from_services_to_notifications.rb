class MoveShowNotificationFromServicesToNotifications < ActiveRecord::Migration[5.0]
  def up
    remove_column :services, :show_notification, :boolean
    add_column :notifications, :show_notification, :boolean
  end

  def down
    remove_column :notifications, :show_notification, :boolean
    add_column :services, :show_notification, :boolean
  end
end
