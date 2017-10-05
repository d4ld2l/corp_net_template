class CreateProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :profiles do |t|
      t.integer :user_id
      t.string :password, :limit => 100
      t.string :surname, :limit => 100
      t.string :name, :limit => 100
      t.string :middlename, :limit => 100
      t.string :photo, :limit => 200
      t.date :birthday
      t.string :position, :limit => 200
      t.string :email_work, :limit => 100
      t.string :email_private, :limit => 100
      t.string :phone_number_landline, :limit => 20
      t.string :phone_number_corporate, :limit => 20
      t.string :phone_number_private, :limit => 20
      t.integer :office_id
      t.string :skype, :limit => 100
      t.string :telegram, :limit => 200
      t.string :vk_url, :limit => 200
      t.string :fb_url, :limit => 200
      t.string :linkedin_url, :limit => 200

      t.timestamps
    end
  end
end
