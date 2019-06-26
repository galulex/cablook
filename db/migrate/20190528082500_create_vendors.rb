class CreateVendors < ActiveRecord::Migration[5.2]
  def change
    create_table :vendors do |t|
      t.string :name
      t.text :description
      t.string :location
      t.string :address
      t.string :url
      t.string :api_url
      t.string :logo_url
      t.time :open_at
      t.time :close_at
    end
  end
end
