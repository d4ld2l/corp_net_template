class CreateAccountVacancies < ActiveRecord::Migration[5.2]
  def change
    create_table :account_vacancies do |t|
      t.references :account, foreign_key: true
      t.references :vacancy, foreign_key: true

      t.timestamps
    end
  end
end
