class AddTripsCountToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :trips_count, :integer, default: 0
    User.find_each do |user|
      trips_count = Trip.where(user_id: user.id).count
      user.update(trips_count: trips_count)
    end
  end
end
