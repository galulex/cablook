class AddActiveStatusToVendors < ActiveRecord::Migration[5.2]
  def change
    add_column :vendors, :active, :boolean, default: true
  end
end
