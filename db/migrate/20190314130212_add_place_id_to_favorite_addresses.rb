class AddPlaceIdToFavoriteAddresses < ActiveRecord::Migration[5.2]
  def change
    add_column :favorite_addresses, :address, :string
    add_column :favorite_addresses, :place_id, :string
  end
end
