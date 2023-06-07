module Jobs
  class BroadcastDriverLocation < ActiveJob::Base

    def perform(car_id, coords, speed, current_trips)
      broadcast_to_map_channel(car_id, coords, speed)
      broadcast_to_trip_channel(current_trips, car_id, coords) unless current_trips.empty?
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

    def broadcast_to_trip_channel(current_trips, car_id, coords)
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
