class AddArrivedAtToTrips < ActiveRecord::Migration[5.1]
  def change
    add_column :trips, :arrived_at, :datetime
  end
end
