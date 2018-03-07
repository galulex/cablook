class AddPhoneNumberToDrivers < ActiveRecord::Migration[5.1]
  def change
    add_column :drivers, :phone_number, :string
  end
end
