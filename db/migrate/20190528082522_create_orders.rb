class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    create_table :orders do |t|
      t.references :user, foreign_key: true
      t.references :vendor, foreign_key: true
      t.references :trip, foreign_key: true
      t.hstore :items
      t.integer :amount

      t.timestamps
    end
  end
end
