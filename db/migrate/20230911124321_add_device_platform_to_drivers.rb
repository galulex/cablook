class AddDevicePlatformToDrivers < ActiveRecord::Migration[5.2]
  def change
    add_column :drivers, :device_platform, :string, default: nil
  end
end
