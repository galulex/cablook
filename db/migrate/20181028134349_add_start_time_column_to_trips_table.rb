class AddStartTimeColumnToTripsTable < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :start_time, :datetime
  end
end
