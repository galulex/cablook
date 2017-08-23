Factory.define(:trip) do |f|
  f.status { [0, 1, 2].sample }
  f.path { fake(:internet, :password) }
  f.cost { fake(:number, :decimal, 2).to_f }
end
