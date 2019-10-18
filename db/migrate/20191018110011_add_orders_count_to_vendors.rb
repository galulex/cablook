class AddOrdersCountToVendors < ActiveRecord::Migration[5.2]
  def change
    add_column :vendors, :orders_count, :integer, default: 0
  end
end
