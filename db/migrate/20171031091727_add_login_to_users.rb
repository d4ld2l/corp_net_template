class AddLoginToUsers < ActiveRecord::Migration[5.0]

  def try_set_login(user, counter)
    if User.find_by(login: user.email.split('@').first + (counter == 0 ? '' : counter.to_s))
      try_set_login(user, counter+1)
    else
      user.login = user.email.split('@').first + (counter == 0 ? '' : counter.to_s)
      puts user.email.split('@').first + (counter == 0 ? '' : counter.to_s)
      user.save!
    end
  end

  def up
    add_column :users, :login, :string
    add_index :users, :login, unique: :true
  end

  def down
    remove_column :users, :login, :string
  end

  def data
    User.reset_column_information
    User.all.each{|x| try_set_login(x, 0)}
  end
end
