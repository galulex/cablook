class AddPhoneNumberToVendors < ActiveRecord::Migration[5.2]
  def change
    add_column :vendors, :phone_number, :string
  end
end
