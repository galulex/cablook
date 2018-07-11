class AddTotalToTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :idle, :integer, :default => 0
    add_column :trips, :total, :integer, :default => 0
  end
end
