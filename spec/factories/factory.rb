FactoryGirl.define do
  factory :user do
    email { Faker::Internet.unique.free_email }
    encrypted_password Devise::Encryptor.digest(User, 'password')
    password 'password'
    confirmed_at Time.zone.now - 1.hour
    confirmation_sent_at Time.zone.now - 2.hours
    association :role
  end

  factory :role, aliases: [:user_role] do
    name { Faker::Pokemon.unique.name }
  end

  factory :company do
    name { Faker::Company.unique.name }
  end

  factory :customer do
    name { Faker::Name.unique.name }
  end

  factory :department do
    association :company
    code { Faker::Code.unique.ean }
    name_ru { Faker::Company.name }
  end

  factory :office do
    name { Faker::Number.unique.between(1, 10) }
  end

  factory :project do
    title { Faker::Hipster.word }
    description { Faker::LordOfTheRings.location }
    manager 1
    association :customer
    begin_date Date.current - 2.month
    end_date Date.current + 2.month
    status { Faker::LordOfTheRings.character }
  end

  factory :user_project do
    association :user
    association :project
  end

  factory :profile do
    association :user
    surname { Faker::Name.last_name }
    sequence :name do |n|
      n
    end
    middlename { Faker::Name.name_with_middle }
    birthday { Faker::Date.birthday(18, 65) }
    association :position
    email_work { Faker::Internet.free_email }
    email_private { Faker::Internet.free_email }
    phone_number_landline { Faker::PhoneNumber.cell_phone }
    phone_number_corporate { Faker::PhoneNumber.cell_phone }
    phone_number_private { Faker::PhoneNumber.cell_phone }
    association :office
    skype { Faker::Superhero.prefix }
  end
end
