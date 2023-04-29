class AddPaymentSystemToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :payment_system, :integer, default: 0
  end
end
