class CreateAccountCommunities < ActiveRecord::Migration[5.2]
  def change
    create_table :account_communities do |t|
      t.references :account, foreign_key: true
      t.references :community, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
