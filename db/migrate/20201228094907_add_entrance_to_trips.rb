class AddEntranceToTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :entrance, :string
  end
end
