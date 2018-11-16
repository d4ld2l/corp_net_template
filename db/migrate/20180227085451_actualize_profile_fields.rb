class ActualizeProfileFields < ActiveRecord::Migration[5.0]
  def up
    add_column :profiles, :social_urls, :json, default: []
    add_column :profiles, :updater_id, :integer, index: true
    remove_column :profiles, :email_private
    remove_column :profiles, :phone_number_private
    remove_column :profiles, :telegram
    remove_column :profiles, :vk_url
    remove_column :profiles, :fb_url
    remove_column :profiles, :linkedin_url
    remove_column :profiles, :instagram_url
  end

  def down
    remove_column :profiles, :social_urls
    remove_column :profiles, :updater_id
    add_column :profiles, :email_private, :string, limit: 100
    add_column :profiles, :phone_number_private, :string, limit: 20
    add_column :profiles, :telegram, :string, limit: 200
    add_column :profiles, :vk_url, :string, limit: 200
    add_column :profiles, :fb_url, :string, limit: 200
    add_column :profiles, :linkedin_url, :string, limit: 200
    add_column :profiles, :instagram_url, :string, limit: 200
  end
end
