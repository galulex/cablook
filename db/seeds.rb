puts 'Creating users...'

def token
  SecureRandom.base58(24)
end
password = BCrypt::Password.create('12341234')

user_data = [
  { phone_number: '+380990000001', encrypted_password: password, auth_token: token },
  { phone_number: '+380990000002', encrypted_password: password, auth_token: token },
  { phone_number: '+380990000003', encrypted_password: password, auth_token: token },
  { phone_number: '+380990000004', encrypted_password: password, auth_token: token },
  { phone_number: '+380990000005', encrypted_password: password, auth_token: token },
]
user_data.each { |data| Repositories::User.new(ROM.env).create(data) }

puts '============================='
puts 'Users created'
puts "=============================\n"

puts 'Creating drivers...'

driver_data = [
  { username: 'driver_1', encrypted_password: password, auth_token: token },
  { username: 'driver_2', encrypted_password: password, auth_token: token },
  { username: 'driver_3', encrypted_password: password, auth_token: token },
  { username: 'driver_4', encrypted_password: password, auth_token: token },
  { username: 'driver_5', encrypted_password: password, auth_token: token },
]
driver_data.each { |data| Repositories::Driver.new(ROM.env).create(data) }

puts '============================='
puts 'Drivers created'
puts "=============================\n"

puts 'Creating cars...'

car_data = [
  { name: '01', status: 0 },
  { name: '02', status: 0 },
  { name: '03', status: 0 },
  { name: '04', status: 0 },
  { name: '05', status: 0 }
]
car_data.each { |data| Repositories::Car.new(ROM.env).create(data) }

puts '============================='
puts 'Cars created'
puts "=============================\n"

puts 'Creating trips...'
location_1 = Sequel.pg_array([49.426334, 32.054184])
location_2 = Sequel.pg_array([49.446263, 32.055930])

trip_data = [
  { status: 0, path: 'test_path', cost: 35.33, departure: location_1, destination: location_2, user_id: 1 },
  { status: 1, path: 'test_path', cost: 14.88, departure: location_1, destination: location_2, user_id: 2 },
  { status: 3, path: 'test_path', cost: 51.51, departure: location_1, destination: location_2, user_id: 3, car_id: 1, driver_id: 1 },
  { status: 4, path: 'test_path', cost: 13.37, departure: location_1, destination: location_2, user_id: 4, car_id: 2, driver_id: 2 },
  { status: 5, path: 'test_path', cost: 22.22, departure: location_1, destination: location_2, user_id: 5 }
]
trip_data.each { |data| Repositories::Trip.new(ROM.env).create(data) }

puts '============================='
puts 'Trips created'
puts "=============================\n"

puts 'Creating trips...'

feedbacks_data = [
  { rate: 1, description: 'so long', user_id: 4, trip_id: 5 }
]
feedbacks_data.each { |data| Repositories::Feedback.new(ROM.env).create(data) }

puts '============================='
puts 'Feedbacks created'
puts "=============================\n"
