class AddVipToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :vip, :boolean, default: false
  end
end
