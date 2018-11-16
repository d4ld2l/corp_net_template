class CreateBidStages < ActiveRecord::Migration[5.0]
  def change
    create_table :bid_stages do |t|
      t.string :name
      t.string :code
      t.references :bid_stages_group, foreign_key: true

      t.timestamps
    end
  end
end
