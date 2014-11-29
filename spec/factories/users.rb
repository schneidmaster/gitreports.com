FactoryGirl.define do
  factory :user do
    username { Faker::Internet.user_name nil, %w(_) }
    name { Faker::Name.name }
    gravatar_id { Faker::Bitcoin.address }
    access_token { Faker::Bitcoin.address }
    repositories { [] }
    organizations { [] }
  end
end
