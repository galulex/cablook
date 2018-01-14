class AddOrderReferenceToPayments < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :order_reference, :string
  end
end
