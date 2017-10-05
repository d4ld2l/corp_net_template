print '  creating roles '
ActiveRecord::Base.transaction do
  roles = %w( admin user manager project_manager)
  roles.each do |name|
    Role.find_or_create_by(name: name)
  end

  Role.where.not(name: roles).delete_all

  puts " (#{Role.count})"
end