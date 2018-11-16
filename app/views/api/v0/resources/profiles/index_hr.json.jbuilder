json.total_count @total_records_for_index
json.profiles do
  json.array! @collection do |elem|
    json.id elem.id
    json.full_name elem.full_name
    json.birthday elem.birthday
    json.photo elem.photo

    json.default_legal_unit do
      if elem&.default_legal_unit_employee
        json.id elem&.default_legal_unit_employee&.legal_unit&.id
        json.legal_unit_employee_id elem&.default_legal_unit_employee&.id
        json.name elem&.default_legal_unit_employee&.legal_unit&.name
        json.position elem&.default_legal_unit_employee&.position&.position&.name_ru
        json.department elem.default_legal_unit_employee&.position&.department&.name_ru
        json.wage_rate elem.default_legal_unit_employee&.wage_rate
        json.structure_unit elem&.default_legal_unit_employee&.structure_unit
      else
        json.null!
      end
    end

    json.legal_units do
      json.array! elem.legal_unit_employees do |lue|
        json.id lue.legal_unit&.id
        json.legal_unit_employee_id lue.id
        json.name lue.legal_unit&.name
        json.position lue.position&.position&.name_ru
        json.department lue&.position&.department&.name_ru
        json.wage_rate lue&.wage_rate
        json.structure_unit lue&.structure_unit
      end
    end
  end
end
