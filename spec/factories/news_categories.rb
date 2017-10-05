FactoryGirl.define do
  factory :news_category do
    name { Faker::RockBand.name }
  end
end
