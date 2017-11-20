module SearchEngine
  class AssignAndBroadcast
    def self.call(attr = {})
      new(attr).call
    end

    def initialize(trip_id:, car_id:, duration:)
      @car_id = car_id
      @trip_id = trip_id
      @duration = duration
    end

    attr_reader :car_id, :trip_id, :duration

    def call
      assign_car_and_driver_to_trip
      update_car_status_to_driving
      broadcast_to_trip_channel
      broadcast_to_drivers_channel
    end

    private

    def assign_car_and_driver_to_trip
      Repositories::Trip.new(ROM.env).update(
        trip_id,
        car_id: car_id,
        driver_id: driver.id
      )
    end

    def update_car_status_to_driving
      Repositories::Car.new(ROM.env).update(
        car_id,
        status: Constants::Trip::DRIVING
      )
    end

    def broadcast_to_trip_channel
      ActionCable.server.broadcast(
        "#{Constants::Channels::TRIP}_#{trip_id}",
        action: Constants::BroadcastActions::TRIP_ASSIGNED,
        car_id: car_id,
        duration: duration
      )
    end

    def broadcast_to_drivers_channel
      ActionCable.server.broadcast(
        Constants::Channels::DRIVER_MAP,
        action: Constants::BroadcastActions::TRIP_ASSIGNED,
        car_id: car_id,
        driver_id: driver.id,
        trip: trip.to_json
      )
    end

    def driver
      @driver ||= Repositories::Driver.new(ROM.env).by_car_id(car_id)
    end

    def trip
      @trip ||= Repositories::Trip.new(ROM.env).by_id_with_user(trip_id)
    end
  end
end
