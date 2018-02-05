Factory.define(:user) do |f|
  f.email { fake(:internet, :email) }
  f.phone_number { "+#{fake(:number, :number, 12)}" }
  f.encrypted_password BCrypt::Password.create('12341234')
  f.auth_token { fake(:internet, :password) }
  f.verification_token { '0305' }
  f.referral_code { Faker::Internet.password(4, 4) }
  f.sequence :verification_token do |n|
    n.to_s.rjust(4, '0')
  end
end
