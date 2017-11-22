module SearchEngine
  class BroadcastPropose
    def self.call(attr = {})
      new(attr).call
    end

    def initialize(cars: [], trip_id:)
      @cars = cars
      @trip_id = trip_id
    end

    attr_reader :cars, :trip_id

    def call
      propose_trip_to_driver
    end

    private

    def propose_trip_to_driver
      ActionCable.server.broadcast(
        Constants::Channels::DRIVER_MAP,
        action: Constants::BroadcastActions::TRIP_PROPOSE,
        cars: cars,
        trip: trip.to_json
      )
    end

    def trip
      @trip ||= Repositories::Trip.new(ROM.env).by_id_with_user(trip_id)
    end
  end
end
