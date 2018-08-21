class CreatePrices < ActiveRecord::Migration[5.2]
  def change
    create_table :prices do |t|
      t.integer :cents_per_km
      t.integer :outside_cents_per_km
      t.integer :landing
      t.integer :fake
      t.integer :idle_price
      t.integer :min_price
      t.float   :coefficient, default: 1
    end
  end
end
