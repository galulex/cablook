FactoryBot.define do
  factory :favorite_address do
    name { Faker::Name.first_name }
    location { '49.4241406,32.0362413' }
    address { 'Active Bridge' }
    place_id { '"ChIJIar5649L0UARx2zALYRK6OE"'}
    association(:user)
  end
end
