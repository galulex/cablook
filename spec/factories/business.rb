FactoryBot.define do
  factory :business do
    association :owner, factory: :user
    association :card
    name { Faker::Name.name }
    email { Faker::Internet.email }
  end
end
