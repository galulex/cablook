Factory.define(:user) do |f|
  f.email { fake(:internet, :email) }
  f.phone_number { "+#{fake(:number, :number, 12)}" }
  f.encrypted_password BCrypt::Password.create('12341234')
  f.auth_token { fake(:internet, :password) }
end
