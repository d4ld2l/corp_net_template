class ChangeUserToAccountInMailingLists < ActiveRecord::Migration[5.2]
  def change
    rename_column :mailing_lists, :user_id, :account_id
  end
end
