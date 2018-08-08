class AddAddressColumnToDrivers < ActiveRecord::Migration[5.2]
  def change
    add_column :drivers, :address, :string
  end
end
