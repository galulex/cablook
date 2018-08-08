class AddAddressLocationColumnToDrivers < ActiveRecord::Migration[5.2]
  def change
    add_column :drivers, :address_location, :decimal, array: true, default: []
  end
end
