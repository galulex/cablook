FactoryBot.define do
  factory :card do
    token { Faker::Internet.password }
    pan { '1234 **' + Faker::Number.number(4).to_s }
    type { %w[Visa MasterCard].sample }
    currency { 'UAH' }
    association(:user)
  end
end
