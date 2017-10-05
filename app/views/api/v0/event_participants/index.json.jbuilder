json.count @collection.total_count
json.took @collection.took
json.results do
  json.array! @collection do |elem|
    json.type elem._index.split('_')&.first&.singularize
    json.item do
      json.partial!('user_fields', user: elem) if elem._index.include?('users')
      json.partial!('department_fields', department: elem) if elem._index.include?('departments')
    end
  end
end