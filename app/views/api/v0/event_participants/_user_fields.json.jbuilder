json.id user&.id&.to_i
json.profile_id user&.profile_id
json.full_name user&.full_name
json.email user&.email
json.email_private user&.email_provate
json.email_work user&.email_work
json.email_corporate user&.email_corporate
json.phone_private user&.phone_private
json.phone_corporate user&.phone_corporate
json.phone_work user&.phone_work
json.position_name user&.position_name
json.departments_chain user&.departments_chain
json.photo user&.photo

# json.email profile&.default_legal_unit_employee&.email_corporate || profile&.default_legal_unit_employee&.email_work || user&.email
# json.position_name profile&.default_legal_unit_employee&.position&.position&.name_ru
# json.department_chain profile&.departments_chain
# json.photo profile.photo
