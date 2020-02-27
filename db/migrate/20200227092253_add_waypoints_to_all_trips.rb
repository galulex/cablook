class AddWaypointsToAllTrips < ActiveRecord::Migration[5.2]
  def change
    Trip.where("waypoints is null OR waypoints[1] != concat(departure[1], ',', departure[2]) OR array_length(waypoints, 1) is null").find_each do |trip|
      begin
        waypoints = trip.waypoints ? trip.waypoints : []
        stops = trip.stops ? trip.stops : []
        waypoints.unshift("#{trip.departure[0]},#{trip.departure[1]}")
        waypoints.push("#{trip.destination[0]},#{trip.destination[1]}")
        stops.unshift(trip.departure_address)
        stops.push(trip.destination_address)
        trip.update(waypoints: waypoints, stops: stops)
      rescue
        next
      end
    end
  end
end
