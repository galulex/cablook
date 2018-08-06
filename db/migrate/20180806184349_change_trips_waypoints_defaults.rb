class ChangeTripsWaypointsDefaults < ActiveRecord::Migration[5.2]
  def change
    change_column_default :trips, :waypoints, []
    change_column_default :trips, :stops, []
  end
end
