class AddZeroTransitionFieldsToBidStagesGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :bid_stages_groups, :initial_executor, :integer
    add_column :bid_stages_groups, :initial_notification, :boolean
    add_column :bid_stages_groups, :initial_notifiable, :jsonb
  end
end
