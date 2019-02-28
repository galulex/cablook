FactoryBot.define do
  factory :favorite_address do
    name { Faker::Name.first_name }
    location { '49.4241406,32.0362413' }
    association(:user)
  end
end
