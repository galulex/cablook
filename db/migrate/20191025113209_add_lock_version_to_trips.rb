class AddLockVersionToTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :trips, :lock_version, :integer, default: 0, null: false
  end
end
