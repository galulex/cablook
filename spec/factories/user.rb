FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    phone_number { "+38063#{Faker::Number.number(7)}" }
    encrypted_password BCrypt::Password.create('12341234')
    auth_token { Faker::Internet.password(4, 4) }
    referral_code { Faker::Internet.password(4, 4) }
    sequence :verification_token do |n|
      n.to_s.rjust(4, '0')
    end
  end
end
