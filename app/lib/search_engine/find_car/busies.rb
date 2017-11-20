module SearchEngine
  module FindCar
    class Busies
      def self.call(trip_id:)
        new(trip_id: trip_id)
      end

      def initialize(trip_id:)
        @trip_id = trip_id
      end

      attr_reader :trip_id

      # find a car from cars which currently at the trip
      # split by [5, 10, 15] minutes to find trips by estimated end time
      def call
        cars = [5, 10, 15].map do |minutes|
          departure = Time.now + minutes.minute
          trips = trip_repository.active_and_estimated_end_in_timeframe(
            from: departure - 5.minute,
            till: departure
          )
          next if trips.empty?
          nearest = NearestPoint.call(
            origins_location: trips.map(&:destination),
            destination: trip.departure,
            departure: departure
          )
          trip = trips.detect { |t| t[:destination] == [nearest.origin.lat, nearest.origin.lng] }
          {
            car_id: trip.car_id,
            duration: nearest.duration_in_traffic_in_seconds
          }
        end.compact
      end

      private

      def car_repository
        @car_repository ||= Repositories::Car.new(ROM.env)
      end

      def trip_repository
        @trip_repository ||= Repositories::Trip.new(ROM.env)
      end
    end
  end
end
