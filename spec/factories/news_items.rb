FactoryGirl.define do
  factory :news_item do
    user nil
    title { Faker::Book.title }
    preview { Faker::Lorem.unique.sentence }
    body { Faker::Lorem.unique.sentence }
    #tags { [0..5].map{|x| Faker::Job.key_skill} }
    on_top [true, false].sample
    published_at "2017-07-05 16:35:50"

    after(:build) do |instance|
      2.times { instance.news_groups << FactoryGirl.create(:news_group) }
      instance.news_category = FactoryGirl.create(:news_category)
      instance.user = FactoryGirl.create(:user)
      2.times { sn.tag_list << Faker::Music.instrument }
    end
  end
end
