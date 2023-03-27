class AddPaymentSystemToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :payment_system, :string
  end
end
