Factory.define(:device) do |f|
  f.token { fake(:internet, :password) }
  f.platform { %w[ios android].sample }
end
