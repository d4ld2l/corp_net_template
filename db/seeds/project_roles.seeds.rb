print '  creating project roles '
ActiveRecord::Base.transaction do
  project_roles = %w(Руководитель Сотрудник)
  # project_roles.each do |name|
  #   ProjectRole.find_or_create_by(name: name)
  # end

  puts " (#{Role.count})"
end