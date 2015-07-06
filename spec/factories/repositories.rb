FactoryGirl.define do
  factory :repository do
    github_id { Faker::Bitcoin.address }
    name { Faker::Lorem.characters(10) }
    is_active true
    display_name ''
    prompt ''
    followup ''
    owner { Faker::Internet.user_name }
    organization
    users { [] }
    allow_issue_title false

    factory :user_repository do
      organization nil
    end
  end
end
