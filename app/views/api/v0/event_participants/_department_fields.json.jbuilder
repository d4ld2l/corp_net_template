json.id department.id&.to_i
json.name department.name
json.logo department&.logo&.as_json
json.employees_count department.participants.count
json.employees do
  json.array! department.participants do |e|
    json.partial!('user_fields', user: e)
  end
end
