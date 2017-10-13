# Must have refactoring and separete logic for free and busy car.
module SearchEngine
  class FindCar
    def self.call(attrs = {})
      new(attrs).call
    end

    def initialize(trip_id:)
      @trip_id = trip_id
    end

    attr_reader :trip_id

    def call
      free_car = nearest_free_car
      busy_car = nearest_busy_car
      if free_car && busy_car
        # with min duration if difference not more 5 min
        result = free_car[:duration] - busy_car[:duration]
        result > 300 ? busy_car : free_car
      else
        free_car || busy_car
      end
    end

    private

    # TODO: Implement logic to take nearest car.
    # It will take car by car_ids where status is `free` and nearest to trip
    def nearest_free_car
      # car_ids = [1, 2]
      car_ids = car_repository.free_cars.map(&:id)
      cars = car_ids.map do |car_id|
        location = redis.get("car_#{car_id}").try(:split, ',')
        { car_id: car_id, location: location } if location
      end.compact
      return if cars.empty?
      # destination = [49.440971, 32.065474]
      locations = cars.map { |car| car[:location] }
      trip = trip_repository.by_id(trip_id)
      nearest = NearestPoint.call(origins_location: locations, destination: trip.departure)
      car = cars.detect { |car| car[:location] == [nearest.origin.lat, nearest.origin.lng] }
      { car_id: car[:car_id], duration: nearest.duration_in_traffic_in_seconds }
    end

    # find a car from cars which currently at the trip
    # split by [5, 10, 15] minutes to find trips by estimated end time
    def nearest_busy_car
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
      cars.min { |car| car[:duration] }
    end

    def car_repository
      @car_repository ||= Repositories::Car.new
    end

    def trip_repository
      @trip_repository ||= Repositories::Trip.new
    end

    def redis
      @redis = Redis.new
    end
  end
end
