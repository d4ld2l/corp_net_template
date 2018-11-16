class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.string 'surname', limit: 100
      t.string 'name', limit: 100
      t.string 'middlename', limit: 100
      t.string 'photo', limit: 200
      t.date 'birthday'
      t.string 'skype', limit: 100
      t.integer 'sex'
      t.string 'city'
      t.jsonb 'social_urls', default: []
      t.integer 'marital_status'
      t.integer 'kids', default: 0, null: false
      t.integer 'balance', default: 0

      t.integer 'updater_id'

      t.string 'email', default: '', null: false
      t.integer 'company_id'
      t.string 'encrypted_password', default: '', null: false
      t.string 'provider', default: 'email', null: false
      t.string 'uid', default: '', null: false
      t.string 'login'
      t.string 'external_id'
      t.string 'external_system'

      t.string 'status', limit: 15

      t.string 'reset_password_token'
      t.datetime 'reset_password_sent_at'
      t.string 'confirmation_token'
      t.datetime 'confirmed_at'
      t.datetime 'confirmation_sent_at'
      t.string 'unconfirmed_email'
      t.datetime 'remember_created_at'
      t.integer 'sign_in_count', default: 0, null: false
      t.datetime 'current_sign_in_at'
      t.datetime 'last_sign_in_at'
      t.inet 'current_sign_in_ip'
      t.inet 'last_sign_in_ip'
      t.jsonb 'tokens'

      t.index ['company_id'], name: 'index_accounts_on_company_id'
      t.index ['company_id', 'email'], name: 'index_accounts_on_company_id_and_email'
      t.index ['company_id', 'login'], name: 'index_accounts_on_company_id_and_login'
      t.index ['confirmation_token'], name: 'index_accounts_on_confirmation_token', unique: true
      t.index ['reset_password_token'], name: 'index_accounts_on_reset_password_token', unique: true

      t.timestamps
    end
  end
end
