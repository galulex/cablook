Factory.define(:trip) do |f|
  f.status 0
  f.path { fake(:internet, :password) }
  f.cost { fake(:number, :decimal, 2).to_f }
end
