class AddAddressGeocoderToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :address_geocoder, :integer, default: 0
  end
end
