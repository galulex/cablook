class AddUserIdToPayments < ActiveRecord::Migration[5.1]
  def change
    add_reference :payments, :user, index: true
  end
end
