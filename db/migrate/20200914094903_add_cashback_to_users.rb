class AddCashbackToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :cashback, :float, default: 0
  end
end
