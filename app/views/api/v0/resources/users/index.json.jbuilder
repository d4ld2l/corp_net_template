json.array! @collection do |elem|
  json.id elem&.profile&.id
  json.full_name elem.full_name
  json.email elem&.profile&.default_legal_unit_employee&.email_corporate || elem&.profile&.default_legal_unit_employee&.email_work || elem&.email
  json.phone (elem&.profile&.default_legal_unit_employee&.phone_corporate || elem&.profile&.default_legal_unit_employee&.phone_work)
  json.photo elem&.profile&.photo
  json.user do
    json.id elem.id
    json.email elem.email
    json.role do
      json.id elem.role&.id
      json.name elem.role&.name
    end
  end
  json.position elem&.profile&.default_legal_unit_employee&.position&.position&.name_ru
  json.department elem&.profile&.default_legal_unit_employee&.position&.department&.name_ru
  json.city elem&.profile&.city
  json.sex elem&.profile&.sex
end
