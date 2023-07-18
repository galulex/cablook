class AddBalanceToDriver < ActiveRecord::Migration[5.2]
  def change
    add_column :drivers, :balance, :integer, default: 0
  end
end
