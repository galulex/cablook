module Jobs
  class BroadcastDriverLocation < ActiveJob::Base
    queue_as :broadcast_location

    def perform
      Car.for_map.each do |car|
        car_data = Redis.current.get("car_data_#{car.id}")
        next unless car_data

        car_data = JSON.parse(car_data).symbolize_keys
        broadcast_to_map_channel(car.id, car.location, car_data[:speed])
        broadcast_to_trip_channel(car.id, car.location, car_data[:current_trips]) unless car_data[:current_trips].empty?
      end
    end

    private

    def broadcast_to_map_channel(car_id, coords, speed)
      ActionCable.server.broadcast(
        Constants::Channels::DRIVER_MAP,
        action: Constants::BroadcastActions::SEND_LOCATION,
        car_id: car_id,
        location: coords,
        speed: speed
      )
    end

    def broadcast_to_trip_channel(car_id, coords, current_trips)
      current_trips.each do |trip_id|
        ActionCable.server.broadcast(
          "#{Constants::Channels::TRIP}_#{trip_id}",
          action: Constants::BroadcastActions::DRIVER_LOCATION_UPDATED,
          body: {
            car_id: car_id,
            location: {
              latitude: coords[0],
              longitude: coords[1]
            }
          }
        )
      end
    end
  end
end
