class CreateBonusInformationApprovers < ActiveRecord::Migration[5.2]
  def change
    create_table :bonus_information_approvers do |t|
      t.references :account, foreign_key: true
      t.references :bonus_information, foreign_key: true

      t.timestamps
    end
  end
end
