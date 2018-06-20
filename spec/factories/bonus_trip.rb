FactoryBot.define do
  factory :bonus_trip do
    status 0
    code { Faker::Internet.password }
    type { Constants::BonusTrip::TYPES.sample }

    association :trip
  end
end
