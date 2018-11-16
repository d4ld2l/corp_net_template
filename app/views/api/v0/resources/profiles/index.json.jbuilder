json.array! @collection do |elem|
  json.id elem.id
  json.full_name elem.full_name
  json.email elem.email
  json.phone elem.phone
  json.photo elem.photo
  json.account do
    json.id elem.account.id
    json.email elem.account.email
    json.roles do
      json.array! elem.account.roles do |role|
        json.id role&.id
        json.name role&.name
      end
    end
  end
  json.position elem.default_legal_unit_employee&.position&.position&.name_ru
  json.department elem.default_legal_unit_employee&.position&.department&.name_ru
  json.city elem.city
  json.sex elem.sex
  json.legal_units do
    json.array! elem.all_legal_unit_employees do |lue|
      json.id lue.legal_unit&.id
      json.legal_unit_employee_id lue.id
      json.name lue.legal_unit&.name
      json.position lue.position&.position&.name_ru
    end
  end
end
