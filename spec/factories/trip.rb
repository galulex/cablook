FactoryBot.define do
  factory :trip do
    status 0
    path { Faker::Internet.password }
    cost { Faker::Number.decimal(2).to_f }

    estimated_end_time { Faker::Time.between(Time.now, Date.today) }

    departure { [Faker::Address.latitude, Faker::Address.longitude] }
    destination { [Faker::Address.latitude, Faker::Address.longitude] }
    departure_address { Faker::Address.street_name }
    destination_address { Faker::Address.street_name }
    comment { Faker::Lorem.sentence }

    association :user

    factory :trip_with_driver do
      association :driver
      association :car
    end
  end

  factory :new_trip, class: Trip do
    departure_address { Faker::Address.street_name }
    destination_address { Faker::Address.street_name }
    departure { 'ChIJIar5649L0UARx2zALYRK6OE' }
    destination { 'ChIJ31p2iHxL0UAR6lpJx2Z3jpM' }
  end
end
