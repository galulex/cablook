Factory.define(:driver) do |f|
  f.name { fake(:name, :name) }
  f.username { fake(:lorem, :word) }
  f.encrypted_password BCrypt::Password.create('12341234')
  f.auth_token { fake(:internet, :password) }
end
