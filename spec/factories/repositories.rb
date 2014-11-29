FactoryGirl.define do
  factory :repository do
    github_id { Faker::Bitcoin.address }
    name { Faker::Lorem.word }
    is_active true
    owner { Faker::Internet.user_name }
    organization
    users { [] }

    factory :user_repository do
      organization nil
    end
  end
end
