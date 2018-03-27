ActiveAdmin.register_page 'Dashboard' do
  content do
    render 'index'
  end

  controller do
    def index
      redis = Redis.current
      @cars = Repositories::Car.new(ROM.env).online_with_driver.map do |car_struct|
        location = redis.get("car_#{car_struct.id}")
        car = car_struct.to_h
        car[:location] = location&.split(',')
        car[:status] = Constants::Car::STATUS_CODES[car_struct.status]
        car
      end

      @trips = Repositories::Trip.new(ROM.env).in_progress
    end
  end
end
