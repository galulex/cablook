FactoryBot.define do
  factory :payment do
    amount { Faker::Number.number(2) }
    status { 0 }
    association :trip
  end
end
