FactoryGirl.define do
  factory :photo do
    name { Faker::Cat.name }
    remote_file_url 'http://www.fillmurray.com/200/400'
  end
end
