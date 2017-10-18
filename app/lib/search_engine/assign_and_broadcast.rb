module SearchEngine
  class AssignAndBroadcast
    def self.call(attr = {})
      new(attr).call
    end

    def initialize(car_id:, duration:, trip_id:)
      @car_id = car_id
      @duration = duration
      @trip_id = trip_id
    end

    attr_reader :car_id, :duration, :trip_id

    def call
      Repositories::Trip.new.update(trip_id, car_id: car_id)
      Repositories::Car.new.update(car_id, status: Constants::Trip::STATUSES[Constants::Trip::DRIVING])
      ActionCable.server.broadcast(
        "#{Constants::TRIP_CHANNEL}_#{trip_id}",
        car_id: car_id,
        duration: duration
      )
    end
  end
end
