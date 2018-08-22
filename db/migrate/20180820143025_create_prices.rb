class CreatePrices < ActiveRecord::Migration[5.2]
  def change
    create_table :prices do |t|
      t.integer :cents_per_km,         default: 600
      t.integer :outside_cents_per_km, default: 900
      t.integer :landing,              default: 2_000
      t.integer :fake,                 default: 20
      t.integer :idle_price,           default: 1
      t.integer :min_price,            default: 4_000
      t.float   :coefficient,          default: 1
    end
    Price.create
  end
end
