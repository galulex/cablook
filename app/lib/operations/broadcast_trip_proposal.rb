module Operations
  class BroadcastTripProposal
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
        trip: Presenters::Trips::Detailed.new(trip).to_json
      )
    end

    def trip
      @trip ||= Trip.find(trip_id)
    end
  end
end
