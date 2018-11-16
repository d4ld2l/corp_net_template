class CreateBonusInformationParticipants < ActiveRecord::Migration[5.2]
  def change
    create_table :bonus_information_participants do |t|
      t.references :account, foreign_key: true
      t.decimal :sum, precision: 12, scale: 2
      t.datetime :period_start
      t.datetime :period_end
      t.references :bonus_information, foreign_key: true
      t.references :legal_unit, foreign_key: true
      t.string :charge_code, null: false, default: ''
      t.text :misc, null: false, default: ''
      t.references :bonus_reason, foreign_key: true

      t.timestamps
    end
  end
end
