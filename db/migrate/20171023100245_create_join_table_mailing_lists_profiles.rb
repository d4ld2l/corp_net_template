class CreateJoinTableMailingListsProfiles < ActiveRecord::Migration[5.0]
  def change
    create_join_table :mailing_lists, :profiles do |t|
      t.index [:mailing_list_id, :profile_id], unique: true
      # t.index [:profile_id, :mailing_list_id]
    end
  end
end
