class ChangeJsonToJsonbInProfiles < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up { change_column :profiles, :social_urls, 'jsonb USING CAST(social_urls AS jsonb)' }
      dir.down { change_column :profiles, :social_urls, 'json USING CAST(social_urls AS json)' }
    end
  end
end
