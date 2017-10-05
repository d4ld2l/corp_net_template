FactoryGirl.define do
  factory :document do
    name { Faker::Commerce.product_name }
    remote_file_url 'http://www.fillmurray.com/200/400'
  end
end
