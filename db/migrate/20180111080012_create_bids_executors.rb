class CreateBidsExecutors < ActiveRecord::Migration[5.0]
  def change
    create_table :bids_executors do |t|
      t.references :user

      t.timestamps
    end
  end
end
