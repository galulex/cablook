ActiveAdmin.register_page 'Dashboard' do
  content do
    render 'index'
  end

  controller do
    def index
      redis = Redis.current
      @cars = Car.where.not(status: Constants::Car::OFFLINE).map do |car_model|
        location = redis.get("car_#{car_model.id}")
        car = car_model.attributes
        car[:location] = location&.split(',')
        car[:status] = Constants::Car::STATUS_CODES[car_model.status]
        car
      end

      @trips = Trip.joins(:users).where(status: [Constants::Trip::PENDING, Constants::Trip::ON_THE_WAY, Constants::Trip::WAITING_CLIENT, Constants::Trip::DRIVING])
    end
  end
end
