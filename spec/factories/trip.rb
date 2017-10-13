Factory.define(:trip) do |f|
  f.status 0
  f.path { fake(:internet, :password) }
  f.cost { fake(:number, :decimal, 2).to_f }

  f.departure { Sequel.pg_array([fake(:address, :latitude), fake(:address, :longitude)]) }
  f.destination { Sequel.pg_array([fake(:address, :latitude), fake(:address, :longitude)]) }
end
