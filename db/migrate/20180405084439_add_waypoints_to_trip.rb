class AddWaypointsToTrip < ActiveRecord::Migration[5.1]
  def change
    add_column :trips, :waypoints, :text, array: true
  end
end
