FactoryGirl.define do
  factory :notification do
    notice nil
    body "MyString"
    dispatch false
    user nil
  end
end
