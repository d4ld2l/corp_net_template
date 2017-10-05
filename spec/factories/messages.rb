FactoryGirl.define do
  factory :message do
    body "MyText"
    topic nil
    parent_message nil
  end
end
