FactoryGirl.define do
  factory :organization do
    name { Faker::Lorem.word }
  end
end
