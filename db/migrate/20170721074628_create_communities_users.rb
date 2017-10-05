class CreateCommunitiesUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :communities_users do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :community, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
