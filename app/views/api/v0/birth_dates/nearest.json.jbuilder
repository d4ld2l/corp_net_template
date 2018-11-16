if @result.keys.any?
  json.set! @result.keys.first, @result.values.first do |profile|
    json.id profile.id
    json.email profile.email
    json.full_name profile.full_name
    json.photo profile.photo
    json.birthday profile.birthday
    json.departments_chain profile.departments_chain
    json.position profile.default_legal_unit_employee&.position&.position&.name_ru
    json.department profile.default_legal_unit_employee&.position&.department&.name_ru
  end
end