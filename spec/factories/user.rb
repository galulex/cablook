Factory.define(:user) do |f|
  f.email { fake(:internet, :email) }
  f.encrypted_password BCrypt::Password.create('12341234')
  f.auth_token { fake(:internet, :password) }
end
