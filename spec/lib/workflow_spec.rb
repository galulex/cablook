describe 'Workflow' do
  # drivers = Array.new(5) do |i|
  #   name = "test_#{i}"
  #   Events::CreateDriver.(name: name, username: username, encrypted_password: '12341234')
  # end

  # cars = Array.new(6) do |i|
  #   name = "test_#{i}"
  #   Events::CreateCar.(name: name, username: username, encrypted_password: '12341234')
  # end

  # users = Array.new(3) do |i|
  #   name = "test_#{i}"
  #   Repositories::User.new(ROM.env).create(
  #     email: "#{name}@cablook.test",
  #     phone_number: "+380991003005#{i}",
  #     encrypted_password: '12341234'
  #   )
  # end

  # ## Drivers login and assign a car

  # it { expect(drivers.first.car_id).to be nil }

  # drivers.each do |driver|
  #   driver_id = driver.id
  #   Events::DriversApp::AssignCar.(driver_id, driver_id)
  #   it { expect(driver_repository.by_id(driver_id).car_id).not_to be nil }
  #   it { expect(car_repository.by_id(driver.car_id).status).to eq(Constants::Car::FREE) }
  # end

  # ## Users create a trips

  # users.each do |user|
  #   Events::CreateTrip.(
  #     path: 'test',
  #     cost: 30,
  #     user_id: user.id,
  #     departure: [rand(49.0..49.5), rand(32.0..32.5)],
  #     destination: [rand(49.0..49.5), rand(32.0..32.5)],
  #     departure_address: 'Test Departure Address',
  #     destination_address: 'Test Destination Address'
  #   )
  # end

  # Driver accept trip


  # user_3 cancel


  # trip - Start


  # trip - Finished
end
