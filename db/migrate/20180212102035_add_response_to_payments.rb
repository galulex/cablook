class AddResponseToPayments < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :response, :jsonb
  end
end
