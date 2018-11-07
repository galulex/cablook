class AddNoCallAndEntranceColumnsToTripsTable < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :no_call, :boolean, default: false
    add_column :trips, :entrance, :integer
  end
end
