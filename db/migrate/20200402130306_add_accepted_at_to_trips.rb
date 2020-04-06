class AddAcceptedAtToTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :accepted_at, :datetime
  end
end
