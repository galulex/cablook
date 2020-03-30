class AddNeedApproveToVendors < ActiveRecord::Migration[5.2]
  def change
    add_column :vendors, :need_approve, :boolean, default: true
  end
end
