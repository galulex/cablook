class AddStopsToTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :stops, :text, array: true
  end
end
