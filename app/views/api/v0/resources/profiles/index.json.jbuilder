json.array! @collection do |elem|
  json.id elem.id
  json.full_name elem.full_name
  json.email elem.default_legal_unit_employee&.email_corporate || elem.default_legal_unit_employee&.email_work || elem.user&.email
  json.phone (elem.default_legal_unit_employee&.phone_corporate || elem.default_legal_unit_employee&.phone_work)
  json.photo elem.photo
  json.user do
    json.id elem.user.id
    json.email elem.user.email
    json.role do
      json.id elem&.user&.role&.id
      json.name elem&.user&.role&.name
    end
  end
  json.position elem.default_legal_unit_employee&.position&.position&.name_ru
  json.department elem.default_legal_unit_employee&.position&.department&.name_ru
  json.city elem.city
  json.sex elem.sex
end
