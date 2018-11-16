class CreateUsersVacancies < ActiveRecord::Migration[5.0]
  def change
    create_table :users_vacancies do |t|
      t.belongs_to :user, index: true
      t.belongs_to :vacancy, index: true
      t.string :full_name
      t.text :comment

      t.timestamps
    end

    remove_column :vacancies, :user_id
  end
end
