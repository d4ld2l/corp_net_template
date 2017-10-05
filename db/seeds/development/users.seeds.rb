require 'faker'
after :roles do
  print '  creating users '
  ActiveRecord::Base.transaction do
    password = "password"
    roles = %w( admin user manager )

    roles.each do |role_name|
      email = role_name + "@example.com"
      role = Role.find_by_name(role_name)
      User.where(email: email).first_or_initialize
          .update!(password: password, email: email, role: role,
                   status: Faker::GameOfThrones.dragon, confirmed_at: Time.current)
    end

    puts " (#{User.count})"
  end
end