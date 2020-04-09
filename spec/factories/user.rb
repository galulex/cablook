FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    phone_number { "+38063#{Faker::Number.number(7)}" }
    auth_token { Faker::Internet.password(4, 4) }
    referral_code { Faker::Internet.password(4, 4) }
  end
end
