class CreateAccountMailingLists < ActiveRecord::Migration[5.2]
  def change
    create_table :account_mailing_lists do |t|
      t.references :account, foreign_key: true
      t.references :mailing_list, foreign_key: true

      t.timestamps
    end
  end
end
