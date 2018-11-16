json.array! @collection do |elem|
  profile =  elem&.profile
  dlue = profile&.default_legal_unit_employee
  json.id elem.id
  json.profile_id elem&.profile&.id
  json.full_name profile.full_name
  json.email elem&.email || dlue&.email_corporate || dlue&.email_work
  json.phone (dlue&.phone_corporate || dlue&.phone_work)
  json.photo profile&.photo
  json.account do
    json.id elem.id
    json.email elem.email
  end
  json.position dlue&.position&.position&.name_ru
  json.department dlue&.position&.department&.name_ru
  json.city profile&.city
  json.sex profile&.sex
end
