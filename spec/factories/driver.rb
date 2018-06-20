FactoryBot.define do
  factory :driver do
    name { Faker::Name.name }
    username { Faker::Lorem.word }
    encrypted_password BCrypt::Password.create('12341234')
    auth_token { Faker::Internet.password }

    factory :driver_with_car do
      association :car
    end
  end
end
