module SearchEngine
  module FindCar
    class Busies
      def self.call(trip_id:)
        new(trip_id: trip_id).call
      end

      def initialize(trip_id:)
        @trip_id = trip_id
      end

      attr_reader :trip_id

      # find a car from cars which currently at the trip
      # split by [5, 10, 15] minutes to find trips by estimated end time
      def call
        cars = [5, 10, 15].map do |interval|
          departure = interval.minutes.since
          trips = trip_repository.active_and_estimated_end_in_timeframe(
            from: departure - 5.minute,
            till: departure
          )
          next if trips.empty?
          nearest = NearestPoint.call(
            origins_location: trips.map(&:destination),
            destination: pending_trip.departure,
            departure: departure.to_i
          )
          trip = trips.detect { |t| t[:destination] == [nearest.origin.lat, nearest.origin.lng] }
          {
            car_id: trip.car_id,
            duration: nearest.duration_in_traffic_in_seconds
          }
        end.compact
        cars.empty? ? nil : cars
      end

      private

      def trip_repository
        @trip_repository ||= Repositories::Trip.new(ROM.env)
      end

      def pending_trip
        @pending_trip ||= trip_repository.by_id(trip_id)
      end
    end
  end
end
