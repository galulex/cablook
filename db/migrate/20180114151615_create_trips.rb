class CreateTrips < ActiveRecord::Migration[5.1]
  def change
    create_table :trips do |t|
      t.integer :status
      t.string :path
      t.decimal :cost, precision: 10, scale: 2
      t.text :departure, array: true, default: []
      t.text :destination, array: true, default: []
      t.string :departure_address
      t.string :destination_address
      t.datetime :estimated_end_time
    end
  end
end
