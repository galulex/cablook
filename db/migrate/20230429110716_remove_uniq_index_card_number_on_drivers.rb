class RemoveUniqIndexCardNumberOnDrivers < ActiveRecord::Migration[5.2]
  def up
    remove_index :drivers, :card_number
  end

  def down
    add_index :drivers, :card_number, unique: true
  end
end
