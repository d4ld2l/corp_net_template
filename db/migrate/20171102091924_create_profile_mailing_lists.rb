class CreateProfileMailingLists < ActiveRecord::Migration[5.0]
  def change
    create_table :profile_mailing_lists do |t|
      t.references :profile, foreign_key: true
      t.references :mailing_list, foreign_key: true
      t.index [:profile_id, :mailing_list_id], unique: true

      t.timestamps
    end
  end
end
