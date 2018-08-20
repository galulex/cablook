class DeleteDriverRelationInPaymentTable < ActiveRecord::Migration[5.2]
  def change
    remove_index "driver_id", name: "index_payments_on_driver_id"
    remove_column :payments, :driver_id
  end
end
