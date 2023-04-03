class AddCardNumberToDrivers < ActiveRecord::Migration[5.2]
  def change
    add_column :drivers, :card_number, :string
    add_index :drivers, :card_number, unique: true
  end
end
