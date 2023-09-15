FactoryBot.define do
  factory :feedback do
    rate { Faker::Number.between(from: 1, to: 5) }
    description { Faker::Lorem.sentence }
  end
end
