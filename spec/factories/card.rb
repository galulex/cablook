Factory.define(:card) do |f|
  f.token { fake(:internet, :password) }
  f.pan { '1234 **' + fake(:number, :number, 4).to_s }
  f.type { %w[Visa MasterCard].sample }
  f.association(:user)
end
