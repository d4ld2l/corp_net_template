print '  creating bid_stages_groups '

ActiveRecord::Base.transaction do
  attributes = [{ name: 'Базовый набор статусов', code: :base }]

  attributes.each { |attr| BidStagesGroup.where(code: attr[:code]).first_or_create!(name: attr[:name]) }

  puts " (#{BidStagesGroup.count})"
end
