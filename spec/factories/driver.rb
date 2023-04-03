FactoryBot.define do
  factory :driver do
    name { Faker::Name.name }
    username { Faker::Lorem.word }
    encrypted_password BCrypt::Password.create('12341234')
    auth_token { Faker::Internet.password }
    card_number { '4444555566661111' }
    factory :driver_with_car do
      association :car
    end
  end
end
