FactoryBot.define do
  factory :payment do
    amount { Faker::Number.number(digits: 2) }
    status { 0 }
    association :trip

    factory :idle_payment, class: Payments::Idle
    factory :fake_taxi_payment, class: Payments::FakeTaxi
    factory :tip_payment, class: Payments::Tip
    factory :trip_payment, class: Payments::Trip
    factory :payout_payment, class: Payments::PayOut
    factory :cash_payment, class: Payments::Cash
  end
end
