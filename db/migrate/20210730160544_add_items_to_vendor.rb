class AddItemsToVendor < ActiveRecord::Migration[5.2]
  def change
    add_column :vendors, :items, :jsonb
  end
end
