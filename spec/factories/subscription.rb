Factory.define(:subscription) do |f|
  f.email { fake(:internet, :email) }
end
