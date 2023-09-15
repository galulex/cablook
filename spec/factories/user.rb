FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    phone_number { "+38063#{Faker::Number.number(digits: 7)}" }
    auth_token { Faker::Internet.password(min_length: 4, max_length: 4) }
    referral_code { Faker::Internet.password(min_length: 4, max_length: 4) }
  end
end
