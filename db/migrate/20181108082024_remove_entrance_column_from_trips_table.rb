class RemoveEntranceColumnFromTripsTable < ActiveRecord::Migration[5.2]
  def change
    remove_column :trips, :entrance
  end
end
