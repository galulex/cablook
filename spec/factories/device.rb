FactoryBot.define do
  factory :device do
    token { Faker::Internet.password }
    platform { %w[ios android].sample }
  end
end
