class AddTinToDrivers < ActiveRecord::Migration[5.2]
  def change
    add_column :drivers, :tin, :string, default: nil
  end
end
