require 'faker'
after :roles do
  print '  creating users '
  ActiveRecord::Base.transaction do
    password = "password"
    roles = %w( admin user )

    roles.each do |role_name|
      email = role_name + "@example.com"
      role = Role.find_by_name(role_name)
      user = User.where(email: email).first_or_initialize
      user.roles << role if user.roles.blank?
      user.update!(password: password, confirmed_at: Time.current, status: :active)
    end

    puts " (#{User.count})"
  end
end