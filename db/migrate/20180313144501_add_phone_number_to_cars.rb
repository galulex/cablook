class AddPhoneNumberToCars < ActiveRecord::Migration[5.1]
  def change
    add_column :cars, :phone_number, :string
    remove_column :drivers, :phone_number
  end
end
