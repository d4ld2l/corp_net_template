after :service_groups, :bid_stages_groups do
  print '  creating services '

  ActiveRecord::Base.transaction do
    attributes = [{ name: 'Представительские расходы', description: 'Описание', bid_stages_group_code: :base, group: 'Финансы и расходы' }]
    attributes = [{ name: 'Bring your own device', description: 'Bring your own device', bid_stages_group_code: :base, group: 'Привилегии сотрудников' }]


    attributes.each do |attr|
      bid_stages_group = BidStagesGroup.find_by_code(attr[:bid_stages_group_code])
      service_group = ServiceGroup.find_by_name(attr[:group])
      Service.where(name: attr[:name]).first_or_create!(description: attr[:description],
                                                        bid_stages_group_id: bid_stages_group.id,
                                                        service_group_id: service_group.id,
                                                        contacts: [User.find_by(login:'admin')]
      )
    end

    puts " (#{Service.count})"
  end
end
