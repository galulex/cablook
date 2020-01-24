class AddWaypointsToOldTrips < ActiveRecord::Migration[5.2]
  def change
    Trip.where("waypoints[1] != concat(departure[1], ',', departure[2]) OR array_length(waypoints, 1) is null").find_each do |trip|
      begin
        trip.waypoints.unshift("#{trip.departure[0]},#{trip.departure[1]}")
        trip.waypoints.push("#{trip.destination[0]},#{trip.destination[1]}")
        trip.stops.unshift(trip.departure_address)
        trip.stops.push(trip.destination_address)
        trip.save
      rescue
        next
      end
    end
  end
end

