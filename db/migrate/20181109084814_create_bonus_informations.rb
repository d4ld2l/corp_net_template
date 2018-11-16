class CreateBonusInformations < ActiveRecord::Migration[5.2]
  def change
    create_table :bonus_informations do |t|
      t.references :bid, foreign_key: true
      t.references :bonus_reason, foreign_key: true
      t.text :additional, null: false, default: ''

      t.timestamps
    end
  end
end
