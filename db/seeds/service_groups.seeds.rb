print '  creating service groups '
ActiveRecord::Base.transaction do
  attributes = [{ name: 'Финансы и расходы' }]

  attributes.each { |attr| ServiceGroup.where(name: attr[:name]).first_or_create! }

  puts " (#{ServiceGroup.count})"
end
