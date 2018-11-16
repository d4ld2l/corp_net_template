class DropJoinTableProfilesMailingLists < ActiveRecord::Migration[5.0]
  def change
    drop_table :mailing_lists_profiles
  end
end
