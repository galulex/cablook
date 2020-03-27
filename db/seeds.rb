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
user_data.each { |data, index| User.create(data.merge(referral_code: SecureRandom.base58(6).upcase)) }

puts '============================='
puts 'Users created'
puts "=============================\n"

puts 'Creating drivers...'

driver_data = [
  { username: 'driver_1', encrypted_password: password, auth_token: token, name: 'Driver 1' },
  { username: 'driver_2', encrypted_password: password, auth_token: token, name: 'Driver 2' },
  { username: 'driver_3', encrypted_password: password, auth_token: token, name: 'Driver 3' },
  { username: 'driver_4', encrypted_password: password, auth_token: token, name: 'Driver 4' },
  { username: 'driver_5', encrypted_password: password, auth_token: token, name: 'Driver 5' },
]
driver_data.each { |data| Driver.create(data) }

puts '============================='
puts 'Drivers created'
puts "=============================\n"

puts 'Creating cars...'

car_data = [
  { number: '01', status: 0, color: 'red' },
  { number: '02', status: 0, color: 'black' },
  { number: '03', status: 0, color: 'white' },
  { number: '04', status: 0, color: 'black' },
  { number: '05', status: 0, color: 'blue' }
]
car_data.each { |data| Car.create(data) }

puts '============================='
puts 'Cars created'
puts "=============================\n"

puts 'Creating trips...'
location_1 = [49.426334, 32.054184]
location_2 = [49.446263, 32.055930]
address = "TestAddress"

trip_data = [
  { status: 0, path: 'test_path', cost: 35.33, departure: location_1, destination: location_2, user_id: 1, departure_address: address, destination_address: address },
  { status: 1, path: 'test_path', cost: 14.88, departure: location_1, destination: location_2, user_id: 2, departure_address: address, destination_address: address },
  { status: 2, path: 'test_path', cost: 51.51, departure: location_1, destination: location_2, user_id: 3, car_id: 1, driver_id: 1, departure_address: address, destination_address: address },
  { status: 3, path: 'test_path', cost: 13.37, departure: location_1, destination: location_2, user_id: 4, car_id: 2, driver_id: 2, departure_address: address, destination_address: address },
  { status: 4, path: 'test_path', cost: 22.22, departure: location_1, destination: location_2, user_id: 5, departure_address: address, destination_address: address }
]
trip_data.each { |data| Trip.create(data) }

puts '============================='
puts 'Trips created'
puts "=============================\n"

puts 'Creating trips...'

feedbacks_data = [
  { rate: 1, description: 'so long', user_id: 4, trip_id: 5 }
]
feedbacks_data.each { |data| Feedback.create(data) }

puts '============================='
puts 'Feedbacks created'
puts "=============================\n"


puts 'Creating bonus trips...'

bonus_trip_data = [
  { status: 1, user_id: 2, friend_id: 3, trip_id: 3, code: 'test_new_1' },
  { status: 1, user_id: 3, friend_id: 4, trip_id: 4, code: 'test_new_2' },
  { status: 1, user_id: 4, friend_id: 5, trip_id: 5, code: 'test_new_3' },
  { status: 0, user_id: 1, friend_id: 1, code: 'test_frozen' }
]
bonus_trip_data.each { |data| BonusTrip.create(data) }
