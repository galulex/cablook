FactoryBot.define do
  factory :feedback do
    rate { Faker::Number.between(1, 5) }
    description { Faker::Lorem.sentence }
  end
end
