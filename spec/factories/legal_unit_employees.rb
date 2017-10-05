FactoryGirl.define do
  factory :legal_unit_employee do
    profile nil
    legal_unit nil
    default false
    employee_number "MyString"
    employee_uid "MyString"
    individual_employee_uid "MyString"
    manager nil
    email_corporate "MyString"
    email_work "MyString"
    phone_corporate "MyString"
    phone_work "MyString"
    office "MyString"
    hired_at "2017-08-16"
    wage 1
    legal_unit_employee_state nil
  end
end
