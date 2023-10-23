class AddTinToDrivers < ActiveRecord::Migration[5.2]
  def change
    add_column :drivers, :inn, :string, default: nil
    add_index :drivers, :inn, unique: true
  end
end
