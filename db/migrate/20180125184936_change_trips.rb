class ChangeTrips < ActiveRecord::Migration[5.1]
  def change
    add_column :trips, :distance, :integer
    add_column :trips, :duration, :integer
    add_column :trips, :start_at, :datetime
    add_column :trips, :finish_at, :datetime
    add_column :trips, :started_at, :datetime
    add_column :trips, :finished_at, :datetime
    change_column :trips, :cost, :integer
  end
end
