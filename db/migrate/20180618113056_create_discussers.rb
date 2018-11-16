class CreateDiscussers < ActiveRecord::Migration[5.0]
  def change
    create_table :discussers do |t|
      t.references :profile, foreign_key: true
      t.references :discussion, foreign_key: true

      t.timestamps
    end
  end
end
