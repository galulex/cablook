class AddTelegramAccountToVendors < ActiveRecord::Migration[5.2]
  def change
    add_column :vendors, :telegram_account, :string
  end
end
