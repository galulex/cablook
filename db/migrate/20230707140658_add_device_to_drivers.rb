class AddDeviceToDrivers < ActiveRecord::Migration[5.2]
  def change
    add_column :drivers, :device, :string
  end
end
