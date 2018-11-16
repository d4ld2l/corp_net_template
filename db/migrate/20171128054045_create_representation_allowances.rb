class CreateRepresentationAllowances < ActiveRecord::Migration[5.0]
  def change
    create_table :representation_allowances do |t|
      t.references :bid, foreign_key: true

      t.timestamps
    end
  end
end
