class AddInstagramUrlToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :instagram_url, :string
  end
end
