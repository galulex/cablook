class AddCashbackToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :cashback, :integer, default: 0
  end
end
