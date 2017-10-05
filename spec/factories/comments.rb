FactoryGirl.define do
  factory :comment do
    news_item nil
    body "MyString"
    user nil
  end
end
