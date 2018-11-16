class AddLeftToDiscusser < ActiveRecord::Migration[5.2]
  def change
    add_column :discussers, :left, :boolean, default: false, null: false
    add_column :discussers, :faved, :boolean, default: false, null: false
    add_column :discussers, :left_at, :datetime
  end
end
