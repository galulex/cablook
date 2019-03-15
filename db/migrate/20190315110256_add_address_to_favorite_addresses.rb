class AddAddressToFavoriteAddresses < ActiveRecord::Migration[5.2]
  def change
    add_column :favorite_addresses, :address, :string
  end
end
