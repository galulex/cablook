Factory.define(:driver) do |f|
  f.name { fake(:lorem, :word) }
  f.auth_token { fake(:internet, :password) }
end
