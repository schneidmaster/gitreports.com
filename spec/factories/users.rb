FactoryGirl.define do
  factory :user do
    username { Faker::Internet.user_name nil, %w(_) }
    name { Faker::Name.name }
    avatar_url { "https://github.com/identicons/#{username}.png" }
    access_token { Faker::Bitcoin.address }
    repositories { [] }
    organizations { [] }
  end
end
