ActiveAdmin.register_page 'Dashboard' do
  content do
    render 'index'
  end

  controller do
    def index
      @cars = Car.for_map.as_json(include: { driver: { only: %i[id name username address] } }, methods: :location)
      @drivers = Driver.all.as_json(only: %i[name username address address_location])
      @trips = Trip.includes(:user).where(status: [Constants::Trip::PENDING, Constants::Trip::ON_THE_WAY, Constants::Trip::WAITING_CLIENT, Constants::Trip::DRIVING])
    end
  end
end
