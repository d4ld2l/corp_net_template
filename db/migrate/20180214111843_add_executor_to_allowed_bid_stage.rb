class AddExecutorToAllowedBidStage < ActiveRecord::Migration[5.0]
  def up
    add_column :allowed_bid_stages, :executor, :integer
    rename_column :allowed_bid_stages, :executor_id, :additional_executor_id
  end

  def down
    remove_column :allowed_bid_stages, :executor, :integer
    rename_column :allowed_bid_stages, :additional_executor_id, :executor_id
  end

  def data
    AllowedBidStage.all.each do |x|
      x.executor = if x.to_assistant?
                     :assistant
                   elsif x.to_author?
                     :author
                   elsif x.to_matching_user?
                     :matching_user
                   end
    end
  end
end
