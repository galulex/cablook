Factory.define(:trip) do |f|
  f.status 0
  f.path { fake(:internet, :password) }
  f.cost { fake(:number, :decimal, 2).to_f }

  f.estimated_end_time { fake(:time, :between, Time.now, Date.today) }

  f.departure { Sequel.pg_array([fake(:address, :latitude), fake(:address, :longitude)]) }
  f.destination { Sequel.pg_array([fake(:address, :latitude), fake(:address, :longitude)]) }
  f.departure_address { fake(:address, :street_name) }
  f.destination_address { fake(:address, :street_name) }
end
