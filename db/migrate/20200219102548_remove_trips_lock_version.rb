class RemoveTripsLockVersion < ActiveRecord::Migration[5.2]
  def change
    remove_column :trips, :lock_version, :integer, default: 0, null: false
  end
end
