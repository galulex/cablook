class AddTypeToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :type, :string, default: 'Payments::Trip'
  end
end
