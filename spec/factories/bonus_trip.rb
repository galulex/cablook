Factory.define(:bonus_trip) do |f|
  f.status { 0 }
  f.code { fake(:internet, :password) }
  f.type { Constants::BonusTrip::TYPES.sample }
end
